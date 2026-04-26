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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Models', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1, color: context.text)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.accent), onPressed: () => ctrl.importModelFromFile()),
            ],
          ),
          const SizedBox(height: 10),
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
                  ).animate().fadeIn(delay: (i * 100).ms).slideX(begin: 0.1, end: 0);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
