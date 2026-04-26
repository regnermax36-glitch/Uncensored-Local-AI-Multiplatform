import 'dart:io';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import '../services/model_manager.dart';
import '../services/llm_service.dart';
import '../models/ai_model_info.dart';

class ModelController extends GetxController {
  final ModelManager _manager = Get.find<ModelManager>();
  final LlmService _llm = Get.find<LlmService>();

  final catalog = <AiModelInfo>[].obs;
  final selectedModelFilename = RxnString();
  final loadingModelFilename = RxnString();
  final loadingProgress = 0.0.obs;
  final loadingStatusMsg = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCatalog();
  }

  void _loadCatalog() {
    catalog.value = _manager.getAvailableModels();
  }

  bool get isModelLoaded => _llm.isLoaded.value;

  Future<void> downloadModel(AiModelInfo model) async {
    await _manager.downloadModel(model);
  }

  Future<void> cancelDownload(String filename) async {
    await _manager.cancelDownload(filename);
  }

  Future<void> deleteModel(String filename) async {
    await _manager.deleteModel(filename);
  }

  Future<void> loadModel(String filename) async {
    if (isModelLoaded && selectedModelFilename.value == filename) return;

    loadingModelFilename.value = filename;
    loadingStatusMsg.value = "Initializing Intelligence...";
    loadingProgress.value = 0.1;

    try {
      final success = await _llm.loadModel(
        p.join(_manager.modelsDir, filename),
        onProgress: (p) {
          loadingProgress.value = 0.1 + (p * 0.9);
          loadingStatusMsg.value = "Loading Weights... ${(p * 100).toInt()}%";
        },
      );

      if (success) {
        selectedModelFilename.value = filename;
      }
    } catch (e) {
      loadingStatusMsg.value = "System Error: $e";
    } finally {
      loadingModelFilename.value = null;
    }
  }

  void unloadCurrentModel() {
    _llm.unloadModel();
    selectedModelFilename.value = null;
  }

  void cancelLoadModel() {
    loadingModelFilename.value = null;
  }

  Future<void> importModelFromFile() async {
    final file = await _manager.pickModelFile();
    if (file != null) _loadCatalog();
  }

  Future<void> importFromDirectory() async {
    await _manager.scanForModels();
    _loadCatalog();
  }

  void deleteCustomModel(AiModelInfo model) {
    _manager.removeCustomModel(model);
    _loadCatalog();
  }
}
