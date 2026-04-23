import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:android_intent_plus/android_intent.dart';

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
    final body = _SettingsBody(showBackButton: !embedded);
    if (embedded) return body;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: body,
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
        Padding(
          padding: EdgeInsets.only(top: showBackButton ? MediaQuery.of(context).padding.top + 12 : 20, left: 24, right: 24, bottom: 12),
          child: Row(
            children: [
              if (showBackButton) IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Get.back()),
              Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: context.text)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _group([
                _tile(context, Icons.dark_mode_rounded, Colors.purple, 'Dark Mode',
                  trailing: Obx(() => Switch.adaptive(value: themeCtrl.isDarkMode, onChanged: (v) => themeCtrl.toggleTheme(), activeColor: Colors.white, activeTrackColor: AppColors.accent))),
              ]),
              _groupTitle('INTELLIGENCE'),
              _group([
                Column(
                  children: [
                    _tile(context, Icons.thermostat_rounded, Colors.orange, 'Creativity'),
                    Obx(() => Slider.adaptive(value: chatCtrl.temperature.value, min: 0, max: 2, divisions: 20, activeColor: AppColors.accent, onChanged: (v) => chatCtrl.updateTemperature(v))),
                  ],
                ),
              ]),
              _groupTitle('ASSISTANT'),
              _group([
                _tile(context, Icons.assistant_rounded, Colors.blue, 'Default Assistant',
                  subtitle: 'Set Apple AI as your default system assistant',
                  onTap: () async {
                    const intent = AndroidIntent(action: 'android.settings.VOICE_INPUT_SETTINGS');
                    await intent.launch();
                  }),
              ]),
              _groupTitle('CONNECTIVITY'),
              _group([
                _tile(context, Icons.api_rounded, Colors.blue, 'Local Server',
                  trailing: Obx(() => Switch.adaptive(value: apiServer.isRunning.value, onChanged: (v) => v ? apiServer.start() : apiServer.stop(), activeColor: Colors.white, activeTrackColor: AppColors.accent))),
                _tile(context, Icons.lan_rounded, Colors.green, 'API Port', trailing: Text(apiServer.port.value.toString(), style: TextStyle(color: context.textD))),
              ]),
              _groupTitle('STORAGE'),
              _group([
                _tile(context, Icons.folder_rounded, Colors.grey, 'Models Path', subtitle: modelManager.modelsDir),
              ]),
              _group([
                _tile(context, Icons.delete_sweep_rounded, Colors.red, 'Clear Memory', titleColor: Colors.red, onTap: () {
                  chatCtrl.chats.clear();
                  chatCtrl.activeChatId.value = null;
                }),
              ]),
              const SizedBox(height: 40),
              Center(child: Text('Apple Intelligence v1.2.0', style: TextStyle(color: context.textD, fontSize: 13))),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _groupTitle(String title) {
    return Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 8), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1)));
  }

  Widget _group(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Get.context!.isDark ? const Color(0xFF1C1C1E) : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _tile(BuildContext context, IconData icon, Color color, String title, {Widget? trailing, String? subtitle, Color? titleColor, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)), child: Icon(icon, color: Colors.white, size: 18)),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: titleColor ?? context.text)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis) : null,
      trailing: trailing,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
