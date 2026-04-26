import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import '../models/ai_model_info.dart';
import '../models/download_state.dart';

class ModelManager extends GetxService {
  final RxList<String> downloadedModels = <String>[].obs;
  final RxMap<String, DownloadState> downloads = <String, DownloadState>{}.obs;
  final RxInt tick = 0.obs;
  late String modelsDir;
  final _metaBox = Hive.box('models_meta');

  Future<ModelManager> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    modelsDir = p.join(appDir.path, 'models');
    await Directory(modelsDir).create(recursive: true);
    await refreshDownloadedModels();
    return this;
  }

  Future<void> refreshDownloadedModels() async {
    final dir = Directory(modelsDir);
    final files = await dir.list().toList();
    downloadedModels.value = files
        .whereType<File>()
        .where((f) => f.path.endsWith('.gguf'))
        .map((f) => p.basename(f.path))
        .toList();
    tick.value++;
  }

  List<AiModelInfo> getAvailableModels() {
    final List<dynamic> customRaw = _metaBox.get('custom_models', defaultValue: []);
    final custom = customRaw.map((m) => AiModelInfo.fromJson(Map<String, dynamic>.from(m))).toList();

    final catalog = [
      AiModelInfo(
        name: 'Llama 3.2 1B (Fast)',
        filename: 'Llama-3.2-1B-Instruct-Q4_K_M.gguf',
        downloadUrl: 'https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf',
        sizeGb: 0.8,
        minRamGb: 2,
        provider: 'Meta',
        description: 'Small and very fast.',
      ),
      AiModelInfo(
        name: 'Phi-3.5 Mini (Smart)',
        filename: 'Phi-3.5-mini-instruct-Q4_K_M.gguf',
        downloadUrl: 'https://huggingface.co/bartowski/Phi-3.5-mini-instruct-GGUF/resolve/main/Phi-3.5-mini-instruct-Q4_K_M.gguf',
        sizeGb: 2.2,
        minRamGb: 4,
        provider: 'Microsoft',
        description: 'Excellent reasoning for its size.',
      ),
    ];

    return [...catalog, ...custom];
  }

  Future<void> downloadModel(AiModelInfo model) async {
    if (downloads.containsKey(model.filename)) return;

    try {
      final request = http.Request('GET', Uri.parse(model.downloadUrl));
      final response = await http.Client().send(request);
      final total = (response.contentLength ?? 0).toDouble();

      final state = DownloadState(filename: model.filename, totalBytes: total);
      downloads[model.filename] = state;

      final file = File(p.join(modelsDir, model.filename));
      final sink = file.openWrite();

      int downloaded = 0;

      await response.stream.map((chunk) {
        downloaded += chunk.length;
        state.receivedBytes = downloaded.toDouble();
        tick.value++;
        return chunk;
      }).pipe(sink);

      await sink.close();
      await refreshDownloadedModels();
    } catch (e) {
      final f = File(p.join(modelsDir, model.filename));
      if (f.existsSync()) f.deleteSync();
    } finally {
      downloads.remove(model.filename);
    }
  }

  bool isDownloading(String filename) => downloads.containsKey(filename);
  DownloadState? getDownloadState(String filename) => downloads[filename];

  Future<void> cancelDownload(String filename) async {
    downloads.remove(filename);
  }

  Future<void> deleteModel(String filename) async {
    final file = File(p.join(modelsDir, filename));
    if (await file.exists()) await file.delete();
    await refreshDownloadedModels();
  }

  Future<String?> pickModelFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      if (path.endsWith('.gguf')) {
        final name = p.basename(path);
        final newPath = p.join(modelsDir, name);
        await File(path).copy(newPath);
        await refreshDownloadedModels();
        return name;
      }
    }
    return null;
  }

  Future<void> scanForModels() async {
    await refreshDownloadedModels();
  }

  void removeCustomModel(AiModelInfo model) {
    final List<dynamic> custom = _metaBox.get('custom_models', defaultValue: []);
    custom.removeWhere((m) => m['filename'] == model.filename);
    _metaBox.put('custom_models', custom);
  }
}
