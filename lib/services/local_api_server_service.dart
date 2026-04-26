import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:llamadart/llamadart.dart';
import 'chat_storage_service.dart';
import 'llm_service.dart';

class LocalApiServerService extends GetxService {
  final LlmService _llm = Get.find<LlmService>();
  final ChatStorageService _storage = Get.find<ChatStorageService>();
  HttpServer? _server;

  final isRunning = false.obs;
  final port = 4891.obs;

  Future<LocalApiServerService> init() async {
    port.value = _storage.localApiServerPort;
    if (_storage.localApiServerEnabled) await start();
    return this;
  }

  Future<void> start() async {
    if (isRunning.value) return;
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port.value);
      isRunning.value = true;
      _storage.localApiServerEnabled = true;
      _server!.listen(_handleRequest);
    } catch (e) {
      isRunning.value = false;
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    isRunning.value = false;
    _storage.localApiServerEnabled = false;
  }

  void _handleRequest(HttpRequest req) async {
    req.response.headers.add('Access-Control-Allow-Origin', '*');
    req.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    req.response.headers.add('Access-Control-Allow-Headers', '*');

    if (req.method == 'OPTIONS') {
      req.response.statusCode = HttpStatus.noContent;
      await req.response.close();
      return;
    }

    try {
      if (req.uri.path == '/v1/models') {
        _sendJson(req, {'object': 'list', 'data': [{'id': _llm.publicModelId, 'object': 'model'}]});
      } else if (req.uri.path == '/v1/chat/completions') {
        final body = await utf8.decoder.bind(req).join();
        final data = jsonDecode(body);
        final messages = (data['messages'] as List).map((m) => LlamaChatMessage.fromText(
          role: m['role'] == 'user' ? LlamaChatRole.user : LlamaChatRole.assistant,
          text: m['content']
        )).toList();

        if (data['stream'] == true) {
          req.response.headers.contentType = ContentType('text', 'event-stream', charset: 'utf-8');
          await for (final token in _llm.generateChatCompletion(messages: messages)) {
            req.response.write('data: ${jsonEncode({'choices': [{'delta': {'content': token}}]})}\n\n');
          }
          req.response.write('data: [DONE]\n\n');
        } else {
          final buffer = StringBuffer();
          await for (final token in _llm.generateChatCompletion(messages: messages)) { buffer.write(token); }
          _sendJson(req, {'choices': [{'message': {'role': 'assistant', 'content': buffer.toString()}}]});
        }
      } else {
        req.response.statusCode = HttpStatus.notFound;
      }
    } catch (e) {
      req.response.statusCode = HttpStatus.internalServerError;
      req.response.write(e.toString());
    } finally {
      await req.response.close();
    }
  }

  void _sendJson(HttpRequest req, Map<String, dynamic> data) {
    req.response.headers.contentType = ContentType.json;
    req.response.write(jsonEncode(data));
  }
}
