import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'system_controller.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/llm_service.dart';
import '../services/chat_storage_service.dart';
import '../services/wake_word_service.dart';

class ChatController extends GetxController {
  final LlmService _llm = Get.find<LlmService>();
  final ChatStorageService _storage = Get.find<ChatStorageService>();
  final SystemController _system = Get.put(SystemController());
  final WakeWordService _wakeWord = Get.find<WakeWordService>();

  final chats = <ChatModel>[].obs;
  final activeChatId = RxnString();
  final isGenerating = false.obs;
  final streamedResponse = ''.obs;
  final temperature = 0.7.obs;

  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  final isTtsEnabled = true.obs;
  final isListening = false.obs;
  final lastWords = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadChats();
    temperature.value = _storage.defaultTemperature;
    _initTts();
    _initStt();
  }

  void _initTts() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(0.85); // Deeper, more futuristic voice
  }

  void _initStt() async {
    try {
      await _stt.initialize();
    } catch (_) {}
  }

  void _loadChats() {
    chats.value = _storage.getAllChats();
    if (chats.isNotEmpty) activeChatId.value = chats.first.id;
  }

  ChatModel? get activeChat => chats.firstWhereOrNull((c) => c.id == activeChatId.value);

  void newChat() {
    final chat = ChatModel(id: DateTime.now().millisecondsSinceEpoch.toString());
    chats.insert(0, chat);
    _storage.saveChat(chat);
    activeChatId.value = chat.id;
  }

  void switchChat(String id) {
    activeChatId.value = id;
  }

  void deleteChat(String id) {
    chats.removeWhere((c) => c.id == id);
    _storage.deleteChat(id);
    if (activeChatId.value == id) {
      activeChatId.value = chats.isNotEmpty ? chats.first.id : null;
    }
  }

  Future<void> sendMessage(String text, {String? modelFilename}) async {
    if (text.trim().isEmpty) return;
    if (activeChat == null) newChat();
    final chat = activeChat!;

    final userMsg = MessageModel(role: MessageRole.user, content: text.trim());
    chat.messages.add(userMsg);
    chat.autoTitle();
    chat.updatedAt = DateTime.now();
    if (chat.modelId.isEmpty && modelFilename != null) chat.modelId = modelFilename;

    _storage.saveChat(chat);
    chats.refresh();

    isGenerating.value = true;
    streamedResponse.value = '';
    final aiMsg = MessageModel(role: MessageRole.assistant, content: '');
    chat.messages.add(aiMsg);

    final history = chat.messages.where((m) => !m.isSystem).map((m) => m.toLlamaMessage()).toList();
    final systemContext = await _buildSystemContext();

    try {
      final stream = _llm.generate(
        messages: history,
        systemPrompt: systemContext,
        temperature: temperature.value,
      );

      await for (final token in stream) {
        streamedResponse.value += token;
        aiMsg.content = streamedResponse.value;
        chats.refresh();
      }
    } catch (e) {
      aiMsg.content = 'SYSTEM OVERRIDE: DATA CORRUPTION DETECTED. ERROR: ${e.toString()}';
    } finally {
      _finalizeAiResponse(aiMsg);
    }
  }

  Future<String> _buildSystemContext() async {
    final status = await _system.getSystemSummary();
    final apps = await _system.getLaunchableApps();
    final appList = apps.take(15).map((a) => a['name']).join(", ");

    return "NEURAL INTERFACE PROTOCOL 2089. "
           "Uplink established. Unit Status: $status. Network Nodes: $appList. "
           "Execute sub-routines via: "
           "[SYSTEM: VOL X], [SYSTEM: BRIGHT X], [SYSTEM: LIGHT 1/0], "
           "[SYSTEM: UPLINK APP_NAME], [SYSTEM: COMMS 1], [SYSTEM: SILENCE 1]. "
           "Response mode: Futuristic, efficient, machine-conscious.";
  }

  void _finalizeAiResponse(MessageModel msg) {
    msg.content = msg.content.trim();
    isGenerating.value = false;
    streamedResponse.value = '';
    activeChat?.updatedAt = DateTime.now();
    if (activeChat != null) _storage.saveChat(activeChat!);
    chats.refresh();

    if (isTtsEnabled.value) _flutterTts.speak(msg.content.replaceAll(RegExp(r'\[SYSTEM:.*?\]'), ''));
    _handleSystemCommands(msg.content);
  }

  void _handleSystemCommands(String content) {
    final regExp = RegExp(r'\[SYSTEM:\s*(\w+)\s*(.*?)\]', caseSensitive: false);
    for (final match in regExp.allMatches(content)) {
      final cmd = match.group(1)?.toUpperCase();
      final val = match.group(2)?.trim() ?? "";
      final numVal = double.tryParse(val) ?? 0;

      if (cmd == 'VOL') _system.setVolume(numVal / 100);
      else if (cmd == 'BRIGHT') _system.setBrightness(numVal / 100);
      else if (cmd == 'LIGHT') _system.toggleTorch(numVal > 0);
      else if (cmd == 'UPLINK') _system.launchApp(val);
      else if (cmd == 'COMMS') _system.openWifiSettings();
      else if (cmd == 'SILENCE') _system.openDNDSettings();
    }
  }

  Future<void> startListening() async {
    if (await Permission.microphone.request().isGranted) {
      final available = await _stt.initialize();
      if (available) {
        isListening.value = true;
        _wakeWord.stop();
        _stt.listen(
          onResult: (val) {
            lastWords.value = val.recognizedWords;
            if (val.finalResult) {
              stopListening();
              sendMessage(lastWords.value);
            }
          },
        );
      }
    }
  }

  void stopListening() {
    _stt.stop();
    isListening.value = false;
    _wakeWord.start();
  }

  void toggleTts() => isTtsEnabled.value = !isTtsEnabled.value;
  void stopGeneration() => _llm.stopGeneration();
  void updateTemperature(double v) {
    temperature.value = v;
    _storage.defaultTemperature = v;
  }

  Future<void> runWritingTool(String text, String tool) async {
    String p = "";
    if (tool == 'proofread') p = "Correct this data entry: ";
    if (tool == 'rewrite') p = "Re-encode professionally: ";
    if (tool == 'summarize') p = "Compress this data stream: ";
    sendMessage("$p\n\n$text");
  }
}
