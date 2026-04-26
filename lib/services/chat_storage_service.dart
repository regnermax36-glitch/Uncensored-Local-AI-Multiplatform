import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/chat_model.dart';

class ChatStorageService extends GetxService {
  late Box<ChatModel> _chatBox;
  late Box _settingsBox;

  Future<ChatStorageService> init() async {
    _chatBox = Hive.box<ChatModel>('chats');
    _settingsBox = Hive.box('settings');
    return this;
  }

  List<ChatModel> getAllChats() {
    final list = _chatBox.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  void saveChat(ChatModel chat) {
    _chatBox.put(chat.id, chat);
  }

  void deleteChat(String id) {
    _chatBox.delete(id);
  }

  // Settings helpers
  double get defaultTemperature => _settingsBox.get('temperature', defaultValue: 0.7);
  set defaultTemperature(double v) => _settingsBox.put('temperature', v);

  bool get localApiServerEnabled => _settingsBox.get('api_enabled', defaultValue: false);
  set localApiServerEnabled(bool v) => _settingsBox.put('api_enabled', v);

  int get localApiServerPort => _settingsBox.get('api_port', defaultValue: 4891);
  set localApiServerPort(int v) => _settingsBox.put('api_port', v);

  String get globalSystemPrompt => _settingsBox.get('system_prompt', defaultValue: '');
  set globalSystemPrompt(String v) => _settingsBox.put('system_prompt', v);
}
