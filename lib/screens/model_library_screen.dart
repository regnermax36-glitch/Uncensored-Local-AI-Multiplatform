import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../controllers/model_controller.dart';
import '../services/model_manager.dart';
import '../models/ai_model_info.dart';
import '../widgets/model_card.dart';

class ModelLibraryScreen extends StatelessWidget {
  final bool embedded;
  const ModelLibraryScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final body = _ModelLibraryBody(showBackButton: !embedded);
    if (embedded) return body;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: body,
    );
  }
}

enum _Filter { all, local, uncensored, custom }

class _ModelLibraryBody extends StatefulWidget {
  final bool showBackButton;
  const _ModelLibraryBody({this.showBackButton = false});

  @override
  State<_ModelLibraryBody> createState() => _ModelLibraryBodyState();
}

class _ModelLibraryBodyState extends State<_ModelLibraryBody> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ModelController>();
    final manager = Get.find<ModelManager>();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: widget.showBackButton ? MediaQuery.of(context).padding.top + 12 : 20, left: 24, right: 24, bottom: 12),
          child: Row(
            children: [
              if (widget.showBackButton) IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Get.back()),
              Text('Intelligence Models', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: context.text)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 28, color: AppColors.accent),
                onPressed: () => _showImportOptions(context, ctrl),
              ),
            ],
          ),
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _chip('Catalog', _Filter.all),
              _chip('On Device', _Filter.local),
              _chip('Uncensored', _Filter.uncensored),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final allCatalog = ctrl.catalog.toList();
            final downloaded = manager.downloadedModels.toList();
            // ignore: unused_local_variable
            final tick = manager.tick.value;

            List<AiModelInfo> filtered;
            switch (_filter) {
              case _Filter.local: filtered = allCatalog.where((m) => downloaded.contains(m.filename)).toList(); break;
              case _Filter.uncensored: filtered = allCatalog.where((m) => m.isUncensored).toList(); break;
              default: filtered = allCatalog;
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ...downloaded.where((f) => !allCatalog.any((m) => m.filename == f)).map((f) => _localFileCard(context, ctrl, f)),
                ...filtered.map((model) => ModelCard(
                  model: model,
                  isDownloaded: downloaded.contains(model.filename),
                  isCurrentlyDownloading: manager.isDownloading(model.filename),
                  downloadState: manager.getDownloadState(model.filename),
                  isLoaded: ctrl.selectedModelFilename.value == model.filename && ctrl.isModelLoaded,
                  isLoadingModel: ctrl.loadingModelFilename.value == model.filename,
                  loadingStatusMsg: ctrl.loadingStatusMsg.value,
                  loadingProgress: ctrl.loadingProgress.value,
                  onDownload: () => ctrl.downloadModel(model),
                  onCancelDownload: () => ctrl.cancelDownload(model.filename),
                  onLoad: () => ctrl.loadModel(model.filename),
                  onDelete: () => ctrl.deleteModel(model.filename),
                  onRemoveCustom: () => ctrl.deleteCustomModel(model),
                  onCancelLoad: () => ctrl.cancelLoadModel(),
                  onUnload: () => ctrl.unloadCurrentModel(),
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95))),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _chip(String label, _Filter filter) {
    final selected = _filter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (v) { if (v) setState(() => _filter = filter); },
        selectedColor: context.isDark ? Colors.white : Colors.black,
        labelStyle: TextStyle(color: selected ? (context.isDark ? Colors.black : Colors.white) : context.text, fontWeight: FontWeight.w600, fontSize: 13),
        backgroundColor: context.isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        showCheckmark: false,
      ),
    );
  }

  Widget _localFileCard(BuildContext context, ModelController ctrl, String filename) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.file_copy_rounded, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(filename, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.text), overflow: TextOverflow.ellipsis)),
          TextButton(onPressed: () => ctrl.loadModel(filename), child: const Text('Initialize', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent))),
        ],
      ),
    );
  }

  void _showImportOptions(BuildContext context, ModelController ctrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(color: context.isDark ? const Color(0xFF1C1C1E) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(40))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2.5))),
            const SizedBox(height: 20),
            Text('Import Intelligence', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.text)),
            const SizedBox(height: 10),
            _importTile(Icons.file_open_rounded, Colors.blue, 'Local File', 'Select .gguf model', () { Navigator.pop(context); ctrl.importModelFromFile(); }),
            _importTile(Icons.folder_copy_rounded, Colors.green, 'Directory Scan', 'Scan for models', () { Navigator.pop(context); ctrl.importFromDirectory(); }),
            _importTile(Icons.cloud_download_rounded, Colors.orange, 'External URL', 'Add remote GGUF', () { Navigator.pop(context); }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _importTile(IconData icon, Color color, String title, String sub, VoidCallback onTap) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      onTap: onTap,
    );
  }
}
