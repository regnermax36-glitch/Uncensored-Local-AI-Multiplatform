import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../theme/app_colors.dart';

class ChatSidebar extends StatelessWidget {
  final VoidCallback onNewChat;
  final Function(String) onSelectChat;
  final Function(String) onDeleteChat;
  final bool showNewChatButton;

  const ChatSidebar({
    super.key,
    required this.onNewChat,
    required this.onSelectChat,
    required this.onDeleteChat,
    this.showNewChatButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final chatCtrl = Get.find<ChatController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(gradient: AppColors.accentGradient, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text('History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.text)),
            ],
          ),
        ),
        Expanded(
          child: Obx(() => ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: chatCtrl.chats.length,
            itemBuilder: (context, index) {
              final chat = chatCtrl.chats[index];
              final isSelected = chatCtrl.activeChatId.value == chat.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(chat.title.isEmpty ? 'New Chat' : chat.title, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.accent : context.text), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(chat.messages.isNotEmpty ? chat.messages.last.content : 'No messages', style: TextStyle(fontSize: 12, color: context.textD), maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => onSelectChat(chat.id),
                  trailing: isSelected ? IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red), onPressed: () => onDeleteChat(chat.id)) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            },
          )),
        ),
      ],
    );
  }
}
