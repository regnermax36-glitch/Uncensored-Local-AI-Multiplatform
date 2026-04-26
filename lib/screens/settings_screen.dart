import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controllers/chat_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/local_api_server_service.dart';

class SettingsScreen extends StatelessWidget {
  final bool embedded;
  const SettingsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final chatCtrl = Get.find<ChatController>();
    final themeCtrl = Get.find<ThemeController>();
    final apiServer = Get.find<LocalApiServerService>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          const SizedBox(height: 20),
          Text('Settings', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1, color: context.text)),
          const SizedBox(height: 24),
          _section(context, 'Appearance', [
            _tile(context, Icons.dark_mode_rounded, Colors.purple, 'Dark Mode',
              trailing: Switch.adaptive(value: themeCtrl.isDarkMode, onChanged: (_) => themeCtrl.toggleTheme(), activeTrackColor: AppColors.accent)),
          ]),
          _section(context, 'Intelligence', [
            _tile(context, Icons.thermostat_rounded, Colors.orange, 'Creativity',
              subtitle: 'Higher values make responses more creative.'),
            Obx(() => Slider.adaptive(value: chatCtrl.temperature.value, min: 0, max: 2, divisions: 20, activeColor: AppColors.accent, onChanged: (v) => chatCtrl.updateTemperature(v))),
          ]),
          _section(context, 'Advanced', [
            _tile(context, Icons.api_rounded, Colors.blue, 'Local API Server',
              trailing: Obx(() => Switch.adaptive(value: apiServer.isRunning.value, onChanged: (v) => v ? apiServer.start() : apiServer.stop(), activeTrackColor: AppColors.accent))),
            _tile(context, Icons.delete_forever_rounded, Colors.red, 'Reset All Chats', onTap: () => chatCtrl.chats.clear()),
          ]),
          const SizedBox(height: 40),
          Center(child: Text('Apple Intelligence for Android v1.2', style: TextStyle(color: context.textD, fontSize: 12))),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 16, bottom: 8), child: Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textD))),
        Container(
          decoration: BoxDecoration(
            color: context.isDark ? const Color(0xFF1C1C1E) : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          ),
          child: Column(children: items),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _tile(BuildContext context, IconData icon, Color color, String title, {String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 18)),
      title: Text(title, style: TextStyle(fontSize: 16, color: context.text)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: context.textD)) : null,
      trailing: trailing,
    );
  }
}
