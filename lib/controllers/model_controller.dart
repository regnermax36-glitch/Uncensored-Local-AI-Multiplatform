import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import '../models/ai_model_info.dart';
import '../models/download_state.dart';
import '../services/model_manager.dart';
import '../services/llm_service.dart';
import '../services/chat_storage_service.dart';

class ModelController extends GetxController {
  final ModelManager _manager = Get.find<ModelManager>();
  final LlmService _llm = Get.find<LlmService>();
  final ChatStorageService _storage = Get.find<ChatStorageService>();

  final selectedModelFilename = RxnString();
  final loadingModelFilename = RxnString();
  final isLoadingModel = false.obs;
  final loadingStatusMsg = ''.obs;
  final loadingProgress = 0.0.obs;
  final loadError = ''.obs;

  List<AiModelInfo> get catalog => _manager.catalog;
  List<String> get downloadedModels => _manager.downloadedModels;
  bool get isModelLoaded => _llm.isLoaded.value;

  @override
  void onInit() {
    super.onInit();
    if (_storage.lastModelId.isNotEmpty) selectedModelFilename.value = _storage.lastModelId;
    ever(_llm.loadingProgress, (double p) => loadingProgress.value = p);
    ever(_llm.loadingStatusMsg, (String m) => loadingStatusMsg.value = m);
  }

  Future<void> downloadModel(AiModelInfo model) async {
    try {
      await _manager.downloadModel(model);
      Get.snackbar('Download Complete', '${model.name} ready');
    } catch (e) {
      Get.snackbar('Download Failed', e.toString());
    }
  }

  void cancelDownload(String filename) => _manager.cancelDownload(filename);

  Future<void> deleteModel(String filename) async {
    await _manager.deleteModel(filename);
    if (selectedModelFilename.value == filename) {
      await _llm.unloadModel();
      selectedModelFilename.value = null;
    }
  }

  Future<void> deleteCustomModel(AiModelInfo model) async {
    await _manager.deleteModel(model.filename);
    _manager.removeCustomModel(model.id);
    if (selectedModelFilename.value == model.filename) {
      await _llm.unloadModel();
      selectedModelFilename.value = null;
    }
  }

  Future<void> loadModel(String filename) async {
    if (isLoadingModel.value) cancelLoadModel();
    loadingModelFilename.value = filename;
    isLoadingModel.value = true;
    try {
      await _llm.loadModel(_manager.getModelPathByFilename(filename));
      selectedModelFilename.value = filename;
      _storage.lastModelId = filename;
    } catch (e) {
      Get.snackbar('Load Failed', e.toString());
    } finally {
      isLoadingModel.value = false;
      loadingModelFilename.value = null;
    }
  }

  void cancelLoadModel() {
    _llm.cancelLoading();
    isLoadingModel.value = false;
  }

  Future<void> unloadCurrentModel() async => await _llm.unloadModel();

  Future<void> importModelFromFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      if (!result.files.single.path!.endsWith('.gguf')) return;
      await _manager.importModel(result.files.single.path!);
    }
  }

  Future<void> importFromDirectory() async {
    final dirPath = await FilePicker.platform.getDirectoryPath();
    if (dirPath == null) return;
    final ggufFiles = await Directory(dirPath).list(recursive: true).where((f) => f is File && f.path.endsWith('.gguf')).toList();
    for (final file in ggufFiles) await _manager.importModel(file.path);
  }

  Future<void> addCustomUrlModel({required String name, required String url}) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final model = AiModelInfo(
      id: id,
      name: name,
      filename: '${name.toLowerCase().replaceAll(' ', '_')}.gguf',
      url: url,
      sizeGb: 0,
      minRamGb: 4,
      label: 'CUSTOM',
      badge: 'USER',
      systemPrompt: '',
    );
    _manager.addCustomModel(model);
    Get.snackbar('Model Added', '$name added to library');
  }

  AiModelInfo? getModelInfo(String filename) {
    try {
      return catalog.firstWhere((m) => m.filename == filename);
    } catch (_) {
      return null;
    }
  }
}
