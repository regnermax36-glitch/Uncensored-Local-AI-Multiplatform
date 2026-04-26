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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                  ? AppColors.accent
                  : (context.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft: Radius.circular(isUser ? 22 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 22),
                ),
                border: isUser ? null : Border.all(color: context.isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
              ),
              child: _buildContent(context, isUser),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
            if (isUser) _buildWritingTools(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWritingTools(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: InkWell(
        onTap: () => _showWritingTools(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: context.isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_fix_high_rounded, size: 12, color: AppColors.purple),
              const SizedBox(width: 6),
              Text('Writing Tools', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.textM)),
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
          color: context.isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const Padding(padding: EdgeInsets.all(20), child: Text('Writing Tools', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
              _toolTile(context, Icons.spellcheck_rounded, Colors.blue, 'Proofread', 'Correct errors', () {
                Get.back(); chatCtrl.runWritingTool(message.content, 'proofread');
              }),
              _toolTile(context, Icons.auto_fix_normal_rounded, Colors.purple, 'Rewrite', 'Polish text', () {
                Get.back(); chatCtrl.runWritingTool(message.content, 'rewrite');
              }),
              _toolTile(context, Icons.summarize_rounded, Colors.orange, 'Summarize', 'Provide summary', () {
                Get.back(); chatCtrl.runWritingTool(message.content, 'summarize');
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolTile(BuildContext context, IconData icon, Color color, String title, String sub, VoidCallback onTap) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: TextStyle(fontSize: 12, color: context.textD)),
      onTap: onTap,
    );
  }

  Widget _buildContent(BuildContext context, bool isUser) {
    if (isUser) return Text(message.content, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.3));
    return MarkdownBody(
      data: message.content,
      selectable: true,
      onTapLink: (text, href, title) { if (href != null) launchUrl(Uri.parse(href)); },
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: context.text, fontSize: 15, height: 1.4),
        code: TextStyle(backgroundColor: context.isDark ? Colors.white10 : Colors.black12, fontSize: 13),
      ),
    );
  }
}
