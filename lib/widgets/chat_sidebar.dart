import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: context.isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
            border: Border(right: BorderSide(color: context.isDark ? Colors.white10 : Colors.black12)),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              if (showNewChatButton) _buildNewChatButton(context),
              Expanded(
                child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: chatCtrl.chats.length,
                  itemBuilder: (context, index) {
                    final chat = chatCtrl.chats[index];
                    final isSelected = chatCtrl.activeChatId.value == chat.id;
                    return _buildChatItem(context, chat, isSelected)
                        .animate()
                        .fadeIn(delay: (index * 50).ms)
                        .slideX(begin: -0.1, end: 0);
                  },
                )),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            'Intelligence',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: context.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewChatButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onNewChat,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.add_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 12),
              Text(
                'New Interaction',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, dynamic chat, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? (context.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: () => onSelectChat(chat.id),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        title: Text(
          chat.title.isEmpty ? 'New Interaction' : chat.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? context.text : context.textM,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          chat.messages.isNotEmpty ? chat.messages.last.content : 'No history yet',
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? context.textM : context.textD,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isSelected
          ? IconButton(
              icon: Icon(Icons.more_horiz_rounded, size: 20, color: context.textD),
              onPressed: () => onDeleteChat(chat.id),
            )
          : null,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: context.isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            child: Icon(Icons.person_rounded, size: 20, color: context.textM),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('System User', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.text)),
                Text('On-Device AI', style: TextStyle(fontSize: 12, color: context.textD)),
              ],
            ),
          ),
          Icon(Icons.settings_rounded, size: 20, color: context.textD),
        ],
      ),
    );
  }
}
