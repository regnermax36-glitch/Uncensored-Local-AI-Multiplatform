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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          const SizedBox(height: 30),
          Text('SYSTEM CORE', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 4, color: context.text)),
          const SizedBox(height: 8),
          Text('INTERFACE PROTOCOL // V2.0.89', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.textD, letterSpacing: 2)),
          const SizedBox(height: 30),

          _cyberSection(context, 'SYNAPSE CONFIG', [
            _cyberTile(context, Icons.lens_blur_rounded, AppColors.neonPurple, 'Neural Dark Mode',
              trailing: Switch.adaptive(value: themeCtrl.isDarkMode, onChanged: (_) => themeCtrl.toggleTheme(), activeTrackColor: context.neonCyan)),
            _cyberTile(context, Icons.waves_rounded, AppColors.neonBlue, 'Cognitive Flow',
              subtitle: 'Adjust generation variance'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Obx(() => Slider.adaptive(value: chatCtrl.temperature.value, min: 0, max: 2, divisions: 20, activeColor: context.neonBlue, onChanged: (v) => chatCtrl.updateTemperature(v))),
            ),
          ]),

          _cyberSection(context, 'NETWORK UPLINK', [
            _cyberTile(context, Icons.terminal_rounded, AppColors.neonCyan, 'Local API Node',
              trailing: Obx(() => Switch.adaptive(value: apiServer.isRunning.value, onChanged: (v) => v ? apiServer.start() : apiServer.stop(), activeTrackColor: context.neonCyan))),
            _cyberTile(context, Icons.security_rounded, Colors.redAccent, 'Purge Memory',
              onTap: () => chatCtrl.chats.clear()),
          ]),

          const SizedBox(height: 40),
          Center(
            child: Opacity(
              opacity: 0.5,
              child: Column(
                children: [
                  Icon(Icons.psychology_rounded, size: 40, color: context.neonCyan),
                  const SizedBox(height: 10),
                  Text('DESIGNED BY NEURAL NETWORKS', style: TextStyle(color: context.textD, fontSize: 8, letterSpacing: 3, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _cyberSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 8, bottom: 12), child: Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: context.neonBlue, letterSpacing: 2))),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.neonBlue.withOpacity(0.1)),
          ),
          child: Column(children: items),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _cyberTile(BuildContext context, IconData icon, Color color, String title, {String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2))),
        child: Icon(icon, color: color, size: 20)
      ),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.text)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 11, color: context.textD)) : null,
      trailing: trailing,
    );
  }
}
