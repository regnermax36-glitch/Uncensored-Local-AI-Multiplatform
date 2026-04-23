import 'dart:async';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'system_controller.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/llm_service.dart';
import '../services/chat_storage_service.dart';

class ChatController extends GetxController {
  final LlmService _llm = Get.find<LlmService>();
  final ChatStorageService _storage = Get.find<ChatStorageService>();
  final SystemController _system = Get.put(SystemController());

  final chats = <ChatModel>[].obs;
  final activeChatId = RxnString();
  final isGenerating = false.obs;
  final streamedResponse = ''.obs;
  final temperature = 0.7.obs;
  final systemPrompt = ''.obs;

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final isListening = false.obs;
  final isTtsEnabled = true.obs;
  final speechEnabled = false.obs;
  final lastWords = ''.obs;

  StreamSubscription<String>? _genSub;

  @override
  void onInit() {
    super.onInit();
    _loadChats();
    temperature.value = _storage.defaultTemperature;
    systemPrompt.value = _storage.globalSystemPrompt;
    _initSpeech();
    _initTts();
  }

  void _initSpeech() async {
    try {
      speechEnabled.value = await _speechToText.initialize();
    } catch (_) {}
  }

  void _initTts() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
  }

  void toggleTts() {
    isTtsEnabled.value = !isTtsEnabled.value;
    if (!isTtsEnabled.value) _flutterTts.stop();
  }

  Future<void> startListening() async {
    if (!speechEnabled.value) {
      if (await Permission.microphone.request().isGranted) {
        speechEnabled.value = await _speechToText.initialize();
      } else {
        return;
      }
    }
    if (speechEnabled.value && !isListening.value) {
      isListening.value = true;
      await _speechToText.listen(onResult: (result) {
        lastWords.value = result.recognizedWords;
        if (result.finalResult) isListening.value = false;
      });
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    isListening.value = false;
  }

  void _loadChats() {
    chats.value = _storage.getAllChats();
  }

  ChatModel? get activeChat {
    if (activeChatId.value == null) return null;
    return chats.firstWhereOrNull((c) => c.id == activeChatId.value);
  }

  void newChat() {
    final chat = ChatModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      systemPrompt: systemPrompt.value,
    );
    chats.insert(0, chat);
    _storage.saveChat(chat);
    activeChatId.value = chat.id;
  }

  void switchChat(String id) {
    activeChatId.value = id;
    final chat = activeChat;
    if (chat != null) systemPrompt.value = chat.systemPrompt;
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
    final chat = activeChat;
    if (chat == null) return;

    final userMsg = MessageModel(role: MessageRole.user, content: text.trim());
    chat.messages.add(userMsg);
    chat.autoTitle();
    chat.updatedAt = DateTime.now();

    if (chat.modelId.isEmpty && modelFilename != null) {
      chat.modelId = modelFilename;
    }

    _storage.saveChat(chat);
    chats.refresh();

    final systemStatus = await _system.getSystemSummary();
    final history = chat.messages.where((m) => !m.isSystem).map((m) => m.toLlamaMessage()).toList();

    final apps = await _system.getLaunchableApps();
    final appNames = apps.map((a) => a.name).join(", ");

    final effectiveSystemPrompt = (chat.systemPrompt.isNotEmpty ? chat.systemPrompt : systemPrompt.value) +
            "\n\nCurrent System Status: $systemStatus\n"
            "Available Apps: $appNames\n"
            "You are Apple Intelligence. You can control the user's device by including these tags in your response:\n"
            "- [SYSTEM: VOLUME X] where X is 0 to 100\n"
            "- [SYSTEM: BRIGHTNESS X] where X is 0 to 100\n"
            "- [SYSTEM: TORCH 1] (on) or [SYSTEM: TORCH 0] (off)\n"
            "- [SYSTEM: WIFI 1] to open Wi-Fi settings\n"
            "- [SYSTEM: BLUETOOTH 1] to open Bluetooth settings\n"
            "- [SYSTEM: SETTINGS 1] to open general system settings\n"
            "- [SYSTEM: OPEN APP_NAME] replace APP_NAME with the exact app name from the list above\n"
            "Use them only when requested.";

    isGenerating.value = true;
    streamedResponse.value = '';
    final aiMsg = MessageModel(role: MessageRole.assistant, content: '');
    chat.messages.add(aiMsg);
    chats.refresh();

    try {
      final stream = _llm.generate(
        messages: history,
        systemPrompt: effectiveSystemPrompt,
        temperature: temperature.value,
      );

      await for (final token in stream) {
        streamedResponse.value += token;
        aiMsg.content = streamedResponse.value;
        chats.refresh();
      }
    } catch (e) {
      if (aiMsg.content.isEmpty) aiMsg.content = '⚠ Error: ${e.toString()}';
    } finally {
      aiMsg.content = aiMsg.content.replaceAll(RegExp(r'<\|.*?\|>|<s>|</s>|\[/?INST\]'), '').trim();
      isGenerating.value = false;
      streamedResponse.value = '';
      chat.updatedAt = DateTime.now();
      _storage.saveChat(chat);
      chats.refresh();
      if (isTtsEnabled.value && aiMsg.content.isNotEmpty) _flutterTts.speak(aiMsg.content);
      _handleSystemCommands(aiMsg.content);
    }
  }

  void _handleSystemCommands(String content) {
    final regExp = RegExp(r'\[SYSTEM:\s*(\w+)\s*(.*?)\]', caseSensitive: false);
    final matches = regExp.allMatches(content);
    for (final match in matches) {
      final command = match.group(1)?.toUpperCase();
      final value = double.tryParse(match.group(2) ?? '0') ?? 0;
      if (command == 'VOLUME') _system.setVolume(value / 100);
      else if (command == 'BRIGHTNESS') _system.setBrightness(value / 100);
      else if (command == 'TORCH') _system.toggleTorch(value > 0);
      else if (command == 'WIFI') _system.openWifiSettings();
      else if (command == 'BLUETOOTH') _system.openBluetoothSettings();
      else if (command == 'SETTINGS') _system.openMainSettings();
      else if (command == 'OPEN') _system.launchApp(match.group(2) ?? "");
    }
  }

  void stopGeneration() {
    _llm.stopGeneration();
    isGenerating.value = false;
  }

  void updateSystemPrompt(String prompt) {
    systemPrompt.value = prompt;
    final chat = activeChat;
    if (chat != null) {
      chat.systemPrompt = prompt;
      _storage.saveChat(chat);
    }
  }

  void setGlobalSystemPrompt(String prompt) {
    systemPrompt.value = prompt;
    _storage.globalSystemPrompt = prompt;
  }

  void clearGlobalSystemPrompt() {
    systemPrompt.value = '';
    _storage.globalSystemPrompt = '';
  }

  void updateTemperature(double temp) {
    temperature.value = temp;
    _storage.defaultTemperature = temp;
  }

  /// Apple Intelligence Writing Tools
  Future<void> runWritingTool(String text, String tool) async {
    String prompt = "";
    switch (tool) {
      case 'proofread': prompt = "Proofread the following text for grammar and spelling errors, providing a corrected version: "; break;
      case 'rewrite': prompt = "Rewrite the following text to be more professional and polished: "; break;
      case 'summarize': prompt = "Provide a concise summary of the following text: "; break;
      case 'key_points': prompt = "Extract the key points from the following text in a bulleted list: "; break;
    }
    if (prompt.isEmpty) return;
    sendMessage("$prompt\n\n$text");
  }

  @override
  void onClose() {
    _genSub?.cancel();
    super.onClose();
  }
}
