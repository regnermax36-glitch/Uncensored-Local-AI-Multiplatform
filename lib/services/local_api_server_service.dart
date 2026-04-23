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
  final isStarting = false.obs;
  final errorMessage = ''.obs;
  final port = 4891.obs;

  String get baseUrl => 'http://127.0.0.1:${port.value}/v1';
  bool get isBusy => _llm.isGenerating.value;
  bool get hasLoadedModel => _llm.isLoaded.value;
  String get modelId => _llm.publicModelId;

  Future<LocalApiServerService> init() async {
    port.value = _storage.localApiServerPort;
    if (_storage.localApiServerEnabled) await start();
    return this;
  }

  Future<void> start() async {
    if (isRunning.value) return;
    isStarting.value = true;
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port.value);
      isRunning.value = true;
      _storage.localApiServerEnabled = true;
      _server!.listen(_handle);
    } catch (e) {
      errorMessage.value = e.toString();
      isRunning.value = false;
    } finally {
      isStarting.value = false;
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    isRunning.value = false;
    _storage.localApiServerEnabled = false;
  }

  Future<void> setPort(int p) async {
    port.value = p;
    _storage.localApiServerPort = p;
    if (isRunning.value) { await stop(); await start(); }
  }

  void _handle(HttpRequest req) async {
    req.response.headers.add('Access-Control-Allow-Origin', '*');
    if (req.method == 'OPTIONS') { req.response.statusCode = HttpStatus.noContent; await req.response.close(); return; }
    try {
      if (req.uri.path == '/v1/models') {
        req.response.write(jsonEncode({'object': 'list', 'data': [{'id': modelId, 'object': 'model'}]}));
      } else if (req.uri.path == '/v1/chat/completions') {
        final body = await utf8.decoder.bind(req).join();
        final data = jsonDecode(body);
        final messages = (data['messages'] as List).map((m) => LlamaChatMessage.fromText(role: m['role'] == 'user' ? LlamaChatRole.user : LlamaChatRole.assistant, text: m['content'])).toList();

        if (data['stream'] == true) {
          req.response.headers.contentType = ContentType('text', 'event-stream', charset: 'utf-8');
          await for (final token in _llm.generateChatCompletion(messages: messages)) {
            req.response.write('data: ${jsonEncode({'choices': [{'delta': {'content': token}}]})}\n\n');
          }
          req.response.write('data: [DONE]\n\n');
        } else {
          final buffer = StringBuffer();
          await for (final token in _llm.generateChatCompletion(messages: messages)) { buffer.write(token); }
          req.response.write(jsonEncode({'choices': [{'message': {'role': 'assistant', 'content': buffer.toString()}}]}));
        }
      } else { req.response.statusCode = HttpStatus.notFound; }
    } catch (e) { req.response.statusCode = HttpStatus.internalServerError; req.response.write(e.toString()); }
    await req.response.close();
  }
}
