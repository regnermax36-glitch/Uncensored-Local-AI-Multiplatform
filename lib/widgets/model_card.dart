import 'package:flutter/material.dart';
import '../models/ai_model_info.dart';
import '../models/download_state.dart';
import '../theme/app_colors.dart';

class ModelCard extends StatelessWidget {
  final AiModelInfo model;
  final bool isDownloaded;
  final bool isCurrentlyDownloading;
  final DownloadState? downloadState;
  final bool isLoaded;
  final bool isLoadingModel;
  final String loadingStatusMsg;
  final double loadingProgress;

  final VoidCallback onDownload;
  final VoidCallback onCancelDownload;
  final VoidCallback onLoad;
  final VoidCallback onDelete;
  final VoidCallback onRemoveCustom;
  final VoidCallback onCancelLoad;
  final VoidCallback onUnload;

  const ModelCard({
    super.key,
    required this.model,
    required this.isDownloaded,
    required this.isCurrentlyDownloading,
    this.downloadState,
    required this.isLoaded,
    required this.isLoadingModel,
    required this.loadingStatusMsg,
    required this.loadingProgress,
    required this.onDownload,
    required this.onCancelDownload,
    required this.onLoad,
    required this.onDelete,
    required this.onRemoveCustom,
    required this.onCancelLoad,
    required this.onUnload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.bolt_rounded, color: AppColors.accent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.text)),
                      const SizedBox(height: 4),
                      Text('${model.sizeGb} GB • ${model.minRamGb} GB RAM', style: TextStyle(fontSize: 12, color: context.textD)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentlyDownloading)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  LinearProgressIndicator(value: downloadState?.progress ?? 0, borderRadius: BorderRadius.circular(4), minHeight: 6, backgroundColor: Colors.black12, valueColor: const AlwaysStoppedAnimation(AppColors.accent)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Downloading... ${( (downloadState?.progress ?? 0) * 100).toInt()}%', style: TextStyle(fontSize: 11, color: context.textM)),
                      const Spacer(),
                      GestureDetector(onTap: onCancelDownload, child: const Text('Cancel', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ],
              ),
            )
          else if (isLoadingModel)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  LinearProgressIndicator(value: loadingProgress, borderRadius: BorderRadius.circular(4), minHeight: 6, backgroundColor: Colors.black12, valueColor: const AlwaysStoppedAnimation(AppColors.green)),
                  const SizedBox(height: 8),
                  Text(loadingStatusMsg, style: TextStyle(fontSize: 11, color: context.textM)),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  if (!isDownloaded)
                    Expanded(child: _actionBtn('Download', AppColors.accent, onDownload))
                  else if (isLoaded)
                    Expanded(child: _actionBtn('Unload', Colors.orange, onUnload))
                  else
                    Expanded(child: _actionBtn('Load', AppColors.green, onLoad)),
                  if (isDownloaded && !isLoaded)
                    IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.red), onPressed: onDelete),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}
