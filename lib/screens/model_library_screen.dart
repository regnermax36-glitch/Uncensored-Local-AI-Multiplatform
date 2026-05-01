import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../controllers/model_controller.dart';
import '../services/model_manager.dart';
import '../widgets/model_card.dart';

class ModelLibraryScreen extends StatelessWidget {
  final bool embedded;
  const ModelLibraryScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ModelController>();
    final manager = Get.find<ModelManager>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Row(
            children: [
              Text('NEURAL UNITS', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 4, color: context.text)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.add_link_rounded, color: context.neonCyan),
                onPressed: () => ctrl.importModelFromFile()
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('CORE DATA STORAGE // UPLINK READY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.textD, letterSpacing: 2)),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              final models = ctrl.catalog;
              final downloaded = manager.downloadedModels;

              return ListView.builder(
                itemCount: models.length,
                itemBuilder: (context, i) {
                  final m = models[i];
                  return ModelCard(
                    model: m,
                    isDownloaded: downloaded.contains(m.filename),
                    isCurrentlyDownloading: manager.isDownloading(m.filename),
                    downloadState: manager.getDownloadState(m.filename),
                    isLoaded: ctrl.selectedModelFilename.value == m.filename && ctrl.isModelLoaded,
                    isLoadingModel: ctrl.loadingModelFilename.value == m.filename,
                    loadingStatusMsg: ctrl.loadingStatusMsg.value,
                    loadingProgress: ctrl.loadingProgress.value,
                    onDownload: () => ctrl.downloadModel(m),
                    onCancelDownload: () => ctrl.cancelDownload(m.filename),
                    onLoad: () => ctrl.loadModel(m.filename),
                    onDelete: () => ctrl.deleteModel(m.filename),
                    onRemoveCustom: () => ctrl.deleteCustomModel(m),
                    onCancelLoad: () => ctrl.cancelLoadModel(),
                    onUnload: () => ctrl.unloadCurrentModel(),
                  ).animate().fadeIn(delay: (i * 100).ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
