import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../models/message_model.dart';
import '../controllers/chat_controller.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isUser
                  ? AppColors.neonBlue.withOpacity(0.15)
                  : (context.isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: Border.all(
                  color: isUser
                    ? AppColors.neonBlue.withOpacity(0.4)
                    : (context.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05))
                ),
                boxShadow: [
                  if (isUser) BoxShadow(color: AppColors.neonBlue.withOpacity(0.2), blurRadius: 15, spreadRadius: -5)
                ],
              ),
              child: _buildContent(context, isUser),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
            if (isUser) _buildWritingTools(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWritingTools(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () => _showWritingTools(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.neonCyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.neonCyan.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_fix_high_rounded, size: 12, color: context.neonCyan),
              const SizedBox(width: 8),
              Text('NEURAL TOOLS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: context.neonCyan, letterSpacing: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _showWritingTools(BuildContext context) {
    final chatCtrl = Get.find<ChatController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: context.isDark ? const Color(0xFF020408) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: context.neonCyan.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('NEURAL DATA MODIFIER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2))
              ),
              _toolTile(context, Icons.psychology_rounded, AppColors.neonBlue, 'Reconstruct Logic', 'Optimize thought patterns', () {
                Get.back(); chatCtrl.runWritingTool(message.content, 'proofread');
              }),
              _toolTile(context, Icons.memory_rounded, AppColors.neonPurple, 'Neural Polish', 'Enhance data clarity', () {
                Get.back(); chatCtrl.runWritingTool(message.content, 'rewrite');
              }),
              _toolTile(context, Icons.compress_rounded, AppColors.neonCyan, 'Data Compression', 'Generate concise summary', () {
                Get.back(); chatCtrl.runWritingTool(message.content, 'summarize');
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolTile(BuildContext context, IconData icon, Color color, String title, String sub, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
        child: Icon(icon, color: color, size: 24)
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      subtitle: Text(sub, style: TextStyle(fontSize: 12, color: context.textD, letterSpacing: 0.5)),
      onTap: onTap,
    );
  }

  Widget _buildContent(BuildContext context, bool isUser) {
    if (isUser) return Text(message.content, style: TextStyle(color: context.text, fontSize: 16, height: 1.4, letterSpacing: 0.2));
    return MarkdownBody(
      data: message.content,
      selectable: true,
      onTapLink: (text, href, title) { if (href != null) launchUrl(Uri.parse(href)); },
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: context.text, fontSize: 16, height: 1.5, letterSpacing: 0.1),
        code: TextStyle(backgroundColor: context.neonBlue.withOpacity(0.1), color: context.neonCyan, fontSize: 14, fontFamily: 'monospace'),
        codeblockDecoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.neonBlue.withOpacity(0.2))),
      ),
    );
  }
}
