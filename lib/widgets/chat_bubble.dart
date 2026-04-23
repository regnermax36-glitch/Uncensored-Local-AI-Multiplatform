import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../models/message_model.dart';
import '../controllers/chat_controller.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser
                  ? AppColors.accent
                  : (context.isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06)),
                borderRadius: BorderRadius.circular(24).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
                boxShadow: [
                  if (!isUser) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: _buildContent(context, isUser),
            ),
            if (isUser) ...[
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _showWritingTools(context, message.content),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_fix_high_rounded, size: 14, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Text('Writing Tools', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.textM)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showWritingTools(BuildContext context, String text) {
    final chatCtrl = Get.find<ChatController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: context.isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const Padding(padding: EdgeInsets.all(20), child: Text('Writing Tools', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              _toolTile(context, Icons.spellcheck_rounded, Colors.blue, 'Proofread', 'Correct grammar and spelling', () {
                Navigator.pop(context); chatCtrl.runWritingTool(text, 'proofread');
              }),
              _toolTile(context, Icons.auto_fix_normal_rounded, Colors.purple, 'Rewrite', 'Make it more professional', () {
                Navigator.pop(context); chatCtrl.runWritingTool(text, 'rewrite');
              }),
              _toolTile(context, Icons.summarize_rounded, Colors.orange, 'Summarize', 'Provide a concise summary', () {
                Navigator.pop(context); chatCtrl.runWritingTool(text, 'summarize');
              }),
              _toolTile(context, Icons.list_alt_rounded, Colors.green, 'Key Points', 'Extract main takeaways', () {
                Navigator.pop(context); chatCtrl.runWritingTool(text, 'key_points');
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolTile(BuildContext context, IconData icon, Color color, String title, String sub, VoidCallback onTap) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 22)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: TextStyle(fontSize: 12, color: context.textD)),
      onTap: onTap,
    );
  }

  Widget _buildContent(BuildContext context, bool isUser) {
    if (isUser) {
      return Text(message.content, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4));
    }
    return MarkdownBody(
      data: message.content,
      selectable: true,
      onTapLink: (text, href, title) {
        if (href != null) launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
      },
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(color: context.text, fontSize: 16, height: 1.5),
        code: TextStyle(backgroundColor: context.isDark ? Colors.white10 : Colors.black12, fontFamily: 'monospace', fontSize: 14),
        codeblockDecoration: BoxDecoration(color: context.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
