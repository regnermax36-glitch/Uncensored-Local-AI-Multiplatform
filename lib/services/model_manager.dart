import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/ai_model_info.dart';
import '../models/download_state.dart';
import 'package:http/http.dart' as http;

class ModelManager extends GetxService {
  final catalog = <AiModelInfo>[].obs;
  final downloadedModels = <String>[].obs;
  final activeDownloads = <String, DownloadState>{}.obs;
  final tick = 0.obs;
  late String _modelsDir;
  http.Client? _httpClient;

  Future<ModelManager> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _modelsDir = p.join(appDir.path, 'AppleAI', 'models');
    await Directory(_modelsDir).create(recursive: true);
    await _loadCatalog();
    await scanDownloaded();
    return this;
  }

  Future<void> _loadCatalog() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/models_catalog.json');
      final list = jsonDecode(jsonStr) as List;
      catalog.value = list.map((j) => AiModelInfo.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {}
    try {
      final box = Hive.box('models_meta');
      final customList = box.get('custom_models', defaultValue: []) as List;
      for (final raw in customList) {
        final m = AiModelInfo.fromJson(Map<String, dynamic>.from(raw as Map));
        if (!catalog.any((x) => x.id == m.id)) catalog.add(m);
      }
    } catch (_) {}
  }

  Future<void> scanDownloaded() async {
    final dir = Directory(_modelsDir);
    if (await dir.exists()) {
      downloadedModels.value = await dir.list().where((f) => f is File && f.path.endsWith('.gguf')).map((f) => p.basename(f.path)).toList();
    }
  }

  String get modelsDir => _modelsDir;
  String getModelPathByFilename(String f) => p.join(_modelsDir, f);
  bool isDownloading(String f) => activeDownloads.containsKey(f);
  DownloadState? getDownloadState(String f) => activeDownloads[f];

  Future<void> downloadModel(AiModelInfo m) async {
    if (isDownloading(m.filename)) return;
    final state = DownloadState(filename: m.filename, totalBytes: m.sizeGb * 1024 * 1024 * 1024);
    activeDownloads[m.filename] = state;

    final file = File(p.join(_modelsDir, m.filename));
    _httpClient = http.Client();

    try {
      final request = http.Request('GET', Uri.parse(m.url));
      final response = await _httpClient!.send(request);
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        if (!activeDownloads.containsKey(m.filename)) break;
        sink.add(chunk);
        state.receivedBytes += chunk.length;
        tick.value++;
      }
      await sink.close();
      await scanDownloaded();
    } finally {
      activeDownloads.remove(m.filename);
    }
  }

  Future<void> deleteModel(String f) async {
    final file = File(p.join(_modelsDir, f));
    if (await file.exists()) await file.delete();
    await scanDownloaded();
  }

  void addCustomModel(AiModelInfo m) {
    if (!catalog.any((x) => x.id == m.id)) {
      catalog.add(m);
      _persist();
    }
  }

  void removeCustomModel(String id) {
    catalog.removeWhere((m) => m.id == id);
    _persist();
  }

  void _persist() {
    final box = Hive.box('models_meta');
    box.put('custom_models', catalog.where((m) => m.isCustom).map((m) => m.toJson()).toList());
  }

  Future<void> importModel(String path) async {
    final filename = p.basename(path);
    await File(path).copy(p.join(_modelsDir, filename));
    await scanDownloaded();
  }

  void cancelDownload(String f) {
    activeDownloads.remove(f);
    if (activeDownloads.isEmpty) {
      _httpClient?.close();
      _httpClient = null;
    }
  }
}
