import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../controllers/chat_controller.dart';
import '../controllers/model_controller.dart';
import '../controllers/system_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/llm_service.dart';
import '../widgets/fluid_glow_painter.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
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
  final _llm = Get.find<LlmService>();
  final _themeCtrl = Get.find<ThemeController>();
  final _system = Get.find<SystemController>();
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sidebarOpen = true;
  bool _autoScrollToBottom = true;
  String? _lastRenderedChatId;

  int _mobileTabIndex = 0;
  final GlobalKey<ScaffoldState> _mobileScaffoldKey = GlobalKey<ScaffoldState>();
  Worker? _speechWorker;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleChatScroll);
    _speechWorker = ever(_chatCtrl.lastWords, (String words) {
      if (words.isNotEmpty && _chatCtrl.isListening.value) {
        _msgController.text = words;
        _msgController.selection = TextSelection.fromPosition(TextPosition(offset: _msgController.text.length));
      }
    });
  }

  @override
  void dispose() {
    _speechWorker?.dispose();
    _scrollController.removeListener(_handleChatScroll);
    _scrollController.dispose();
    _msgController.dispose();
    super.dispose();
  }

  void _handleChatScroll() {
    if (!_scrollController.hasClients) return;
    _autoScrollToBottom = _scrollController.position.maxScrollExtent - _scrollController.position.pixels <= 120;
  }

  void _scrollToBottom({bool force = false}) {
    if (!force && !_autoScrollToBottom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  void _send() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _chatCtrl.lastWords.value = '';
    if (_chatCtrl.activeChat == null) _chatCtrl.newChat();
    _msgController.clear();
    _autoScrollToBottom = true;
    _chatCtrl.sendMessage(text, modelFilename: _modelCtrl.selectedModelFilename.value);
    _scrollToBottom(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    return Obx(() => FluidGlowPainter(
      isVisible: _chatCtrl.isListening.value || _chatCtrl.isGenerating.value,
      child: Scaffold(
        key: _mobileScaffoldKey,
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        drawer: _buildDrawer(),
        body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
        bottomNavigationBar: isDesktop ? null : _buildMobileNav(),
      ),
    ));
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: context.isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SafeArea(
          child: ChatSidebar(
            onNewChat: () { _chatCtrl.newChat(); Navigator.pop(context); },
            onSelectChat: (id) { _chatCtrl.switchChat(id); Navigator.pop(context); },
            onDeleteChat: (id) => _chatCtrl.deleteChat(id),
            showNewChatButton: true,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: IndexedStack(
        index: _mobileTabIndex,
        children: [
          _buildMobileChatTab(),
          const ModelLibraryScreen(embedded: true),
          const SettingsScreen(embedded: true),
        ],
      ),
    );
  }

  Widget _buildMobileChatTab() {
    return Column(
      children: [
        _buildMobileTopBar(),
        _buildSystemDashboard(),
        Expanded(child: _buildChatArea()),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildMobileTopBar() {
    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.glassDark : AppColors.glassLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight),
      ),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.menu_rounded, color: context.textM), onPressed: () => _mobileScaffoldKey.currentState?.openDrawer()),
          Expanded(child: Center(child: _buildModelSelector())),
          IconButton(icon: Icon(Icons.add_rounded, color: context.textM), onPressed: () => _chatCtrl.newChat()),
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    return Obx(() {
      final fname = _modelCtrl.selectedModelFilename.value;
      final loaded = _llm.isLoaded.value;
      return Text(loaded ? (fname ?? 'Model') : 'No Model', style: TextStyle(fontWeight: FontWeight.w600, color: context.text));
    });
  }

  Widget _buildMobileNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.glassDark : AppColors.glassLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: context.isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: _mobileTabIndex,
          onTap: (i) => setState(() => _mobileTabIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: context.textM,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.widgets_rounded), label: 'Models'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        if (_sidebarOpen) SizedBox(width: 280, child: _buildDrawer()),
        Expanded(
          child: Column(
            children: [
              _buildMobileChatTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatArea() {
    return Obx(() {
      final chat = _chatCtrl.activeChat;
      if (chat == null || chat.messages.isEmpty) return _buildWelcome();
      _scrollToBottom();
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: chat.messages.length + (_chatCtrl.isGenerating.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < chat.messages.length) {
            return ChatBubble(message: chat.messages[index]);
          }
          return const Padding(
            padding: EdgeInsets.all(20),
            child: TypingIndicator(),
          );
        },
      );
    });
  }

  Widget _buildSystemDashboard() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.glassDark : AppColors.glassLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _sysItem(icon: Icons.battery_full, label: '${_system.batteryLevel.value}%', color: Colors.green),
          _sysItem(icon: Icons.volume_up, label: '${(_system.currentVolume.value * 100).toInt()}%', color: Colors.blue),
          _sysItem(icon: Icons.brightness_6, label: '${(_system.currentBrightness.value * 100).toInt()}%', color: Colors.orange),
        ],
      ),
    ));
  }

  Widget _sysItem({required IconData icon, required String label, required Color color}) {
    return Row(children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.textM))]);
  }

  Widget _buildWelcome() {
    return Center(child: Text('Apple Intelligence', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.textM)));
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.isDark ? AppColors.glassDark : AppColors.glassLight,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: context.isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight),
            ),
            child: Row(
              children: [
                IconButton(icon: Icon(_chatCtrl.isTtsEnabled.value ? Icons.volume_up_rounded : Icons.volume_off_rounded, color: AppColors.accent), onPressed: _chatCtrl.toggleTts),
                Expanded(child: TextField(controller: _msgController, decoration: const InputDecoration(hintText: 'Ask Apple AI...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)))),
                IconButton(icon: Icon(_chatCtrl.isListening.value ? Icons.mic_rounded : Icons.mic_none_rounded, color: _chatCtrl.isListening.value ? Colors.red : AppColors.accent), onPressed: _chatCtrl.isListening.value ? _chatCtrl.stopListening : _chatCtrl.startListening),
                IconButton(icon: Icon(_chatCtrl.isGenerating.value ? Icons.stop_circle_rounded : Icons.arrow_upward_rounded, color: AppColors.accent), onPressed: _chatCtrl.isGenerating.value ? _chatCtrl.stopGeneration : _send),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
