import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      if (listening) _showOverlay.value = true;
    });

    ever(_chatCtrl.lastWords, (String words) {
      if (_chatCtrl.isListening.value) _msgController.text = words;
    });
  }

  void _initWakeWord() async {
    await _wakeWord.init();
    _wakeWord.onWakeWordDetected.listen((_) => _chatCtrl.startListening());
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
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 400), curve: Curves.easeOutQuart);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
      children: [
        // 2089 Background Matrix
        Container(color: context.isDark ? AppColors.darkBg : AppColors.lightBg),

        FluidGlowPainter(
          isVisible: _chatCtrl.isGenerating.value || _chatCtrl.isListening.value,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            extendBodyBehindAppBar: true,
            drawer: Drawer(
              backgroundColor: Colors.transparent,
              width: MediaQuery.of(context).size.width * 0.85,
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
                  _buildNeuralChatTab(),
                  const ModelLibraryScreen(embedded: true),
                  const SettingsScreen(embedded: true),
                ],
              ),
            ),
            bottomNavigationBar: _buildFuturisticNav(),
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

  Widget _buildNeuralChatTab() {
    return Column(
      children: [
        _buildCyberHeader(),
        Expanded(child: _buildNeuralChatList()),
        _buildSuggestionPills(),
        _buildFloatingInput(),
      ],
    );
  }

  Widget _buildCyberHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Builder(builder: (c) => InkWell(
            onTap: () => Scaffold.of(c).openDrawer(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: Colors.white10)),
              child: Icon(Icons.grid_view_rounded, color: context.neonCyan, size: 20),
            ),
          )),
          const Spacer(),
          Column(
            children: [
              Text('NEURAL CORE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 3, color: context.text)),
              Obx(() => Text(_modelCtrl.selectedModelFilename.value?.toUpperCase() ?? 'WAITING FOR UPLINK...', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: context.neonBlue, letterSpacing: 1))),
            ],
          ),
          const Spacer(),
          _buildPowerStatus(),
        ],
      ),
    );
  }

  Widget _buildPowerStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.neonPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.neonPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt_rounded, size: 14, color: context.neonPurple),
          const SizedBox(width: 4),
          Text('${_system.batteryLevel.value}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: context.neonPurple)),
        ],
      ),
    );
  }

  Widget _buildNeuralChatList() {
    final chat = _chatCtrl.activeChat;
    if (chat == null || chat.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology_rounded, size: 80, color: context.neonCyan).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.ms * 1000),
            const SizedBox(height: 24),
            Text('INITIATE NEURAL LINK', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: context.textD, letterSpacing: 4)),
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

  Widget _buildSuggestionPills() {
    if (_chatCtrl.isGenerating.value) return const SizedBox.shrink();
    final suggestions = ['ANALYZE SYSTEM', 'QUERY DATABASE', 'NEURAL STATUS'];
    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => InkWell(
          onTap: () { _msgController.text = suggestions[i]; _send(); },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.neonBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.neonBlue.withOpacity(0.2)),
            ),
            child: Text(suggestions[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: context.neonBlue, letterSpacing: 1)),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: context.neonCyan.withOpacity(0.2)),
              boxShadow: [BoxShadow(color: context.neonCyan.withOpacity(0.1), blurRadius: 20, spreadRadius: -5)],
            ),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.mic_none_rounded, color: context.neonBlue, size: 24), onPressed: () => _chatCtrl.startListening()),
                Expanded(child: TextField(
                  controller: _msgController,
                  style: TextStyle(color: context.text, fontSize: 16),
                  decoration: InputDecoration(hintText: 'COMMAND...', hintStyle: TextStyle(color: context.textD, letterSpacing: 2, fontWeight: FontWeight.bold), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16))
                )),
                InkWell(
                  onTap: _chatCtrl.isGenerating.value ? _chatCtrl.stopGeneration : _send,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(gradient: AppColors.accentGradient, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 10)]),
                    child: Icon(_chatCtrl.isGenerating.value ? Icons.stop_rounded : Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFuturisticNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      height: 70,
      decoration: BoxDecoration(
        color: context.isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: context.neonCyan.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, Icons.chat_bubble_outline_rounded, 'DATA'),
            _navItem(1, Icons.layers_outlined, 'UNITS'),
            _navItem(2, Icons.settings_input_component_rounded, 'CORE'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _mobileTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _mobileTabIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: selected ? context.neonCyan : context.textD, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: selected ? context.neonCyan : context.textD, letterSpacing: 1.5)),
        ],
      ),
    );
  }
}
