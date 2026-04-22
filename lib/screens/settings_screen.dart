import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../controllers/chat_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/local_api_server_service.dart';
import '../services/model_manager.dart';

class SettingsScreen extends StatelessWidget {
  final bool embedded;
  const SettingsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    if (embedded) return _SettingsBody(showBackButton: false);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _SettingsBody(showBackButton: true),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  final bool showBackButton;
  const _SettingsBody({this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final chatCtrl = Get.find<ChatController>();
    final themeCtrl = Get.find<ThemeController>();
    final apiServer = Get.find<LocalApiServerService>();
    final modelManager = Get.find<ModelManager>();

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: showBackButton ? MediaQuery.of(context).padding.top + 8 : 12, left: 8, right: 8, bottom: 8),
          child: Row(
            children: [
              if (showBackButton) IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.text), onPressed: () => Get.back()),
              const SizedBox(width: 8),
              Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.text)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section(context, 'Appearance', [
                Obx(() => SwitchListTile(
                  title: const Text('Dark Mode'),
                  secondary: Icon(themeCtrl.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.accent),
                  value: themeCtrl.isDarkMode,
                  onChanged: (v) => themeCtrl.toggleTheme(),
                  activeColor: AppColors.accent,
                )),
              ]),
              _section(context, 'AI Configuration', [
                Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.only(left: 16, bottom: 8), child: Text('Temperature', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                    Slider(
                      value: chatCtrl.temperature.value,
                      min: 0, max: 2, divisions: 20,
                      activeColor: AppColors.accent,
                      onChanged: (v) => chatCtrl.updateTemperature(v),
                    ),
                  ],
                )),
              ]),
              _section(context, 'Local API', [
                Obx(() => Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Local API Server'),
                      subtitle: Text(apiServer.baseUrl, style: const TextStyle(fontSize: 11)),
                      value: apiServer.isRunning.value,
                      onChanged: (v) => v ? apiServer.start() : apiServer.stop(),
                      activeColor: AppColors.accent,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'API Port', hintText: '1234'),
                        keyboardType: TextInputType.number,
                        onSubmitted: (v) => apiServer.setPort(int.tryParse(v) ?? 4891),
                      ),
                    ),
                  ],
                )),
              ]),
              _section(context, 'Storage', [
                ListTile(
                  leading: const Icon(Icons.folder_rounded, color: AppColors.accent),
                  title: const Text('Model Storage Path'),
                  subtitle: Text(modelManager.modelsDir, style: const TextStyle(fontSize: 11)),
                ),
              ]),
              _section(context, 'Danger Zone', [
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: const Text('Delete All Chats', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    chatCtrl.chats.clear();
                    chatCtrl.activeChatId.value = null;
                    Get.snackbar('Cleared', 'All chats deleted');
                  },
                ),
              ]),
              const SizedBox(height: 32),
              Center(child: Text('Apple Intelligence v1.1.0', style: TextStyle(color: context.textD, fontSize: 12))),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(color: context.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.textD, letterSpacing: 1))),
          ...children,
        ],
      ),
    );
  }
}
