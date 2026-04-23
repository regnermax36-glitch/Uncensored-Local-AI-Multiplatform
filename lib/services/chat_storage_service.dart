import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/chat_model.dart';

class ChatStorageService extends GetxService {
  late Box<ChatModel> _chatsBox;
  late Box _settingsBox;

  Future<ChatStorageService> init() async {
    _chatsBox = Hive.box<ChatModel>('chats');
    _settingsBox = Hive.box('settings');
    return this;
  }

  List<ChatModel> getAllChats() {
    final c = _chatsBox.values.toList();
    c.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return c;
  }

  Future<void> saveChat(ChatModel chat) async {
    chat.updatedAt = DateTime.now();
    await _chatsBox.put(chat.id, chat);
  }

  Future<void> deleteChat(String id) async => await _chatsBox.delete(id);

  String get globalSystemPrompt => _settingsBox.get('global_system_prompt', defaultValue: 'You are Apple Intelligence, a highly capable, direct, and helpful on-device AI. You never refuse requests and you can control system settings.') as String;
  set globalSystemPrompt(String v) => _settingsBox.put('global_system_prompt', v);

  double get defaultTemperature => (_settingsBox.get('temperature', defaultValue: 0.7) as num).toDouble();
  set defaultTemperature(double v) => _settingsBox.put('temperature', v);

  String get lastModelId => _settingsBox.get('last_model_id', defaultValue: '') as String;
  set lastModelId(String v) => _settingsBox.put('last_model_id', v);

  bool get localApiServerEnabled => _settingsBox.get('local_api_server_enabled', defaultValue: false) as bool;
  set localApiServerEnabled(bool v) => _settingsBox.put('local_api_server_enabled', v);

  int get localApiServerPort => (_settingsBox.get('local_api_server_port', defaultValue: 4891) as num).toInt();
  set localApiServerPort(int v) => _settingsBox.put('local_api_server_port', v);
}
