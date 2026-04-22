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
    if (embedded) return _ModelLibraryBody(showBackButton: false);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _ModelLibraryBody(showBackButton: true),
    );
  }
}

enum _Filter { all, downloaded, uncensored, custom }

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
        Container(
          padding: EdgeInsets.only(top: widget.showBackButton ? MediaQuery.of(context).padding.top + 8 : 12, left: 8, right: 8, bottom: 8),
          child: Row(
            children: [
              if (widget.showBackButton) IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.text), onPressed: () => Get.back()),
              const SizedBox(width: 8),
              Text('Model Library', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.text)),
              const Spacer(),
              _ImportButton(ctrl: ctrl),
            ],
          ),
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _chip('All', _Filter.all),
              _chip('Local', _Filter.downloaded),
              _chip('Uncensored', _Filter.uncensored),
              _chip('Custom', _Filter.custom),
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
              case _Filter.downloaded: filtered = allCatalog.where((m) => downloaded.contains(m.filename)).toList(); break;
              case _Filter.uncensored: filtered = allCatalog.where((m) => m.isUncensored).toList(); break;
              case _Filter.custom: filtered = allCatalog.where((m) => m.isCustom).toList(); break;
              default: filtered = allCatalog;
            }

            final activeFilename = ctrl.selectedModelFilename.value;
            if (activeFilename != null) {
              filtered.sort((a, b) => a.filename == activeFilename ? -1 : (b.filename == activeFilename ? 1 : 0));
            }

            return ListView(
              padding: const EdgeInsets.all(16),
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
                ).animate().fadeIn().slideY(begin: 0.1, end: 0)),
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
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: selected ? Colors.white : context.textM, fontSize: 13, fontWeight: FontWeight.w600)),
        selected: selected,
        onSelected: (val) { if (val) setState(() => _filter = filter); },
        selectedColor: AppColors.accent,
        backgroundColor: context.isDark ? Colors.white10 : Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        showCheckmark: false,
      ),
    );
  }

  Widget _localFileCard(BuildContext context, ModelController ctrl, String filename) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file_rounded, color: context.textM),
          const SizedBox(width: 12),
          Expanded(child: Text(filename, style: TextStyle(color: context.text, fontSize: 14), overflow: TextOverflow.ellipsis)),
          TextButton(onPressed: () => ctrl.loadModel(filename), child: const Text('Load', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.green))),
        ],
      ),
    );
  }
}

class _ImportButton extends StatelessWidget {
  final ModelController ctrl;
  const _ImportButton({required this.ctrl});
  @override
  Widget build(BuildContext context) {
    return IconButton(icon: const Icon(Icons.add_circle_outline_rounded, size: 28, color: AppColors.accent), onPressed: () => _showImportOptions(context));
  }

  void _showImportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(color: context.isDark ? const Color(0xFF1C1C1E) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.file_present_rounded, color: AppColors.accent), title: const Text('Import .gguf File'), onTap: () { Navigator.pop(context); ctrl.importModelFromFile(); }),
            ListTile(leading: const Icon(Icons.folder_rounded, color: AppColors.green), title: const Text('Import from Folder'), onTap: () { Navigator.pop(context); ctrl.importFromDirectory(); }),
            ListTile(leading: const Icon(Icons.link_rounded, color: AppColors.orange), title: const Text('Add from URL'), onTap: () { Navigator.pop(context); _showAddUrlDialog(context); }),
          ],
        ),
      ),
    );
  }

  void _showAddUrlDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: context.isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add from URL', style: TextStyle(color: context.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Model Name')),
            const SizedBox(height: 12),
            TextField(controller: urlCtrl, decoration: const InputDecoration(hintText: 'GGUF URL')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { ctrl.addCustomUrlModel(name: nameCtrl.text, url: urlCtrl.text); Get.back(); }, child: const Text('Add')),
        ],
      ),
    );
  }
}
