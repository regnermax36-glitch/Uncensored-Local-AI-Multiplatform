import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/model_controller.dart';
import '../controllers/system_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/wake_word_service.dart';
import '../widgets/apple_intelligence_overlay.dart';
import '../widgets/fluid_glow_painter.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../theme/app_colors.dart';
import 'model_library_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _chatCtrl = Get.find<ChatController>();
  final _modelCtrl = Get.find<ModelController>();
  final _system = Get.find<SystemController>();
  final _wakeWord = Get.find<WakeWordService>();
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();

  int _mobileTabIndex = 0;
  final _showOverlay = false.obs;

  @override
  void initState() {
    super.initState();
    _initWakeWord();

    ever(_chatCtrl.isListening, (bool listening) {
      if (listening) {
        _showOverlay.value = true;
      }
    });

    ever(_chatCtrl.lastWords, (String words) {
      if (_chatCtrl.isListening.value) {
        _msgController.text = words;
      }
    });
  }

  void _initWakeWord() async {
    await _wakeWord.init();
    _wakeWord.onWakeWordDetected.listen((_) {
      _chatCtrl.startListening();
    });
    _wakeWord.start();
  }

  void _send() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    _chatCtrl.sendMessage(text, modelFilename: _modelCtrl.selectedModelFilename.value);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
      children: [
        FluidGlowPainter(
          isVisible: _chatCtrl.isGenerating.value || _chatCtrl.isListening.value,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            extendBodyBehindAppBar: true,
            drawer: Drawer(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ChatSidebar(
                onNewChat: () { _chatCtrl.newChat(); Get.back(); },
                onSelectChat: (id) { _chatCtrl.switchChat(id); Get.back(); },
                onDeleteChat: (id) => _chatCtrl.deleteChat(id),
              ),
            ),
            body: SafeArea(
              child: IndexedStack(
                index: _mobileTabIndex,
                children: [
                  _buildChatTab(),
                  const ModelLibraryScreen(embedded: true),
                  const SettingsScreen(embedded: true),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomNav(),
          ),
        ),
        AppleIntelligenceOverlay(
          isVisible: _showOverlay.value,
          onDismiss: () {
            _showOverlay.value = false;
            _chatCtrl.stopListening();
          },
        ),
      ],
    ));
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildChatList()),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Builder(builder: (c) => IconButton(icon: Icon(Icons.menu_rounded, color: context.text), onPressed: () => Scaffold.of(c).openDrawer())),
          const Spacer(),
          Column(
            children: [
              Text('Apple Intelligence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.text)),
              Obx(() => Text(_modelCtrl.selectedModelFilename.value ?? 'No Model Loaded', style: TextStyle(fontSize: 10, color: context.textD))),
            ],
          ),
          const Spacer(),
          _buildSystemStats(),
        ],
      ),
    );
  }

  Widget _buildSystemStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: context.isDark ? Colors.white10 : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.battery_4_bar_rounded, size: 12, color: AppColors.green),
          const SizedBox(width: 4),
          Text('${_system.batteryLevel.value}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.textM)),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    final chat = _chatCtrl.activeChat;
    if (chat == null || chat.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 60, color: AppColors.purple),
            const SizedBox(height: 16),
            Text('Ready for Intelligence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.textM)),
          ],
        ),
      );
    }
    _scrollToBottom();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: chat.messages.length + (_chatCtrl.isGenerating.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < chat.messages.length) return ChatBubble(message: chat.messages[index]);
        return const TypingIndicator();
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: context.isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                IconButton(icon: Icon(_chatCtrl.isTtsEnabled.value ? Icons.volume_up_rounded : Icons.volume_off_rounded, color: AppColors.accent, size: 20), onPressed: _chatCtrl.toggleTts),
                Expanded(child: TextField(controller: _msgController, decoration: const InputDecoration(hintText: 'Ask Intelligence...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12)))),
                IconButton(icon: Icon(Icons.mic_rounded, color: AppColors.accent, size: 20), onPressed: () => _chatCtrl.startListening()),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    child: Icon(_chatCtrl.isGenerating.value ? Icons.stop_rounded : Icons.arrow_upward_rounded, color: Colors.white, size: 18),
                  ),
                  onPressed: _chatCtrl.isGenerating.value ? _chatCtrl.stopGeneration : _send,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: context.isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: context.isDark ? Colors.white10 : Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            currentIndex: _mobileTabIndex,
            onTap: (i) => setState(() => _mobileTabIndex = i),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.accent,
            unselectedItemColor: context.textD,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Icons.hub_rounded), label: 'Models'),
              BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}
