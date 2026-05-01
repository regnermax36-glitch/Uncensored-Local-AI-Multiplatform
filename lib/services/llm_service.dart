import 'dart:async';
import 'package:get/get.dart';
import 'package:llamadart/llamadart.dart';

class LlmService extends GetxService {
  LlamaEngine? _engine;
  ChatSession? _session;
  final isLoaded = false.obs;
  final isGenerating = false.obs;
  String publicModelId = 'none';

  Future<bool> loadModel(String path, {Function(double)? onProgress}) async {
    unloadModel();
    try {
      _engine = LlamaEngine(LlamaBackend());

      // Initial progress
      onProgress?.call(0.1);

      await _engine!.loadModel(path);

      // Final progress
      onProgress?.call(1.0);

      isLoaded.value = true;
      publicModelId = path.split('/').last;
      return true;
    } catch (e) {
      isLoaded.value = false;
      return false;
    }
  }

  void unloadModel() {
    _engine?.dispose();
    _engine = null;
    _session = null;
    isLoaded.value = false;
    publicModelId = 'none';
  }

  Stream<String> generate({
    required List<LlamaChatMessage> messages,
    required String systemPrompt,
    double temperature = 0.7,
  }) async* {
    if (_engine == null) return;
    isGenerating.value = true;

    try {
      _session ??= ChatSession(_engine!);
      _session!.systemPrompt = systemPrompt;

      _session!.reset(keepSystemPrompt: true);
      for (final m in messages) {
        _session!.addMessage(m);
      }

      final stream = _session!.create([], params: GenerationParams(temp: temperature));

      await for (final chunk in stream) {
        final content = chunk.choices.first.delta.content;
        if (content != null) yield content;
      }
    } finally {
      isGenerating.value = false;
    }
  }

  Stream<String> generateChatCompletion({required List<LlamaChatMessage> messages}) {
    return generate(messages: messages, systemPrompt: "Helpful assistant.");
  }

  void stopGeneration() {
    isGenerating.value = false;
  }
}
