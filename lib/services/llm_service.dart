import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:llamadart/llamadart.dart';
import 'package:path/path.dart' as p;

class LlmService extends GetxService {
  LlamaEngine? _engine;
  LlamaBackend? _backend;

  final isLoaded = false.obs;
  final isGenerating = false.obs;
  final loadedModelPath = ''.obs;
  final tokensPerSecond = 0.0.obs;
  final lastGenerationSpeed = 0.0.obs;

  final isLoadingModel = false.obs;
  final loadingProgress = 0.0.obs;
  final loadingStatusMsg = ''.obs;
  bool _loadingCancelled = false;

  Future<LlmService> init() async => this;

  void cancelLoading() => _loadingCancelled = true;

  String get publicModelId {
    if (loadedModelPath.isEmpty) return 'local';
    return p.basenameWithoutExtension(loadedModelPath.value);
  }

  Future<void> loadModel(String path) async {
    final file = File(path);
    if (!await file.exists()) throw Exception('Model not found');
    _loadingCancelled = false;
    isLoadingModel.value = true;
    loadingProgress.value = 0.1;
    loadingStatusMsg.value = 'Intelligizing...';
    await unloadModel();
    _backend = LlamaBackend();
    _engine = LlamaEngine(_backend!);
    try {
      final params = ModelParams(contextSize: 2048, gpuLayers: 0, preferredBackend: GpuBackend.cpu, numberOfThreads: 4);
      await _engine!.loadModel(path, modelParams: params);
      if (_loadingCancelled) {
        await unloadModel();
        return;
      }
      isLoaded.value = true;
      loadedModelPath.value = path;
    } catch (e) {
      await unloadModel();
      rethrow;
    } finally {
      isLoadingModel.value = false;
    }
  }

  Stream<String> generate({required List<Map<String, String>> messages, String? systemPrompt, double temperature = 0.7}) async* {
    if (_engine == null) throw StateError('Engine not ready');
    isGenerating.value = true;
    final stopwatch = Stopwatch()..start();
    int count = 0;
    final prompt = _buildPrompt(messages, systemPrompt);
    await for (final token in _engine!.generate(prompt)) {
      count++;
      tokensPerSecond.value = count / (stopwatch.elapsedMilliseconds / 1000);
      yield token;
    }
    lastGenerationSpeed.value = tokensPerSecond.value;
    isGenerating.value = false;
  }

  Future<void> stopGeneration() async => isGenerating.value = false;
  Future<void> unloadModel() async {
    await _engine?.dispose();
    _engine = null;
    _backend = null;
    isLoaded.value = false;
    loadedModelPath.value = '';
  }

  String _buildPrompt(List<Map<String, String>> messages, String? sys) {
    final b = StringBuffer();
    if (sys != null) b.writeln('<|system|>\n$sys\n<|end|>');
    for (final m in messages) b.writeln('<|${m['role']}|>\n${m['content']}\n<|end|>');
    b.writeln('<|assistant|>');
    return b.toString();
  }

  Future<int> countTokens(String text) async {
    if (_engine == null) return 0;
    return await _engine!.getTokenCount(text);
  }

  Stream<String> generateChatCompletion({required List<LlamaChatMessage> messages, GenerationParams params = const GenerationParams()}) async* {
    if (_engine == null) throw StateError('Engine not ready');
    isGenerating.value = true;
    final stopwatch = Stopwatch()..start();
    int count = 0;
    try {
      await for (final chunk in _engine!.create(messages, params: params)) {
        final content = chunk.choices.firstOrNull?.delta.content;
        if (content == null) continue;
        count++;
        tokensPerSecond.value = count / (stopwatch.elapsedMilliseconds / 1000);
        yield content;
      }
    } finally {
      lastGenerationSpeed.value = tokensPerSecond.value;
      isGenerating.value = false;
    }
  }
}
