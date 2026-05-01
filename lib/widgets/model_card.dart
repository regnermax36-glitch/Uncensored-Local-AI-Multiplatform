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
        color: context.isDark ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        boxShadow: [
          if (!context.isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: model.isUncensored
                        ? [Colors.deepPurple, Colors.purpleAccent]
                        : [Colors.blue, Colors.cyanAccent],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (model.isUncensored ? Colors.purple : Colors.blue).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Icon(model.isUncensored ? Icons.psychology_rounded : Icons.hub_rounded, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: context.text, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _tag(model.provider, Colors.grey),
                          const SizedBox(width: 8),
                          _tag('${model.sizeGb}GB', Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isDownloaded && !isCurrentlyDownloading && !isLoadingModel)
                  _statusIndicator(isLoaded ? Icons.check_circle_rounded : Icons.download_done_rounded, isLoaded ? AppColors.green : Colors.blue),
              ],
            ),
          ),
          if (isCurrentlyDownloading)
            _buildProgress(context, 'Downloading Intelligence...', downloadState?.progress ?? 0, onCancelDownload)
          else if (isLoadingModel)
            _buildProgress(context, loadingStatusMsg, loadingProgress, onCancelLoad)
          else
            _buildActions(context),
        ],
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _statusIndicator(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildProgress(BuildContext context, String msg, double progress, VoidCallback onCancel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(msg, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.textM)),
              const Spacer(),
              Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent)),
              const SizedBox(width: 12),
              InkWell(
                onTap: onCancel,
                child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.isDark ? Colors.white10 : Colors.black.withOpacity(0.03))),
      ),
      child: Row(
        children: [
          if (!isDownloaded)
            Expanded(child: _btn(context, 'GET', AppColors.accent, onDownload))
          else if (isLoaded)
            Expanded(child: _btn(context, 'UNLOAD', Colors.orange, onUnload))
          else
            Expanded(child: _btn(context, 'INITIALIZE', AppColors.green, onLoad)),
          if (isDownloaded && !isLoaded)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
