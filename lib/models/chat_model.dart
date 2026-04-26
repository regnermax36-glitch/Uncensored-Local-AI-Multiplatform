import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/message_model.dart';

part 'chat_model.g.dart';

@HiveType(typeId: 0)
class ChatModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  List<MessageModel> messages;
  @HiveField(3)
  DateTime updatedAt;
  @HiveField(4)
  String modelId;
  @HiveField(5)
  String systemPrompt;

  ChatModel({
    required this.id,
    this.title = '',
    List<MessageModel>? messages,
    DateTime? updatedAt,
    this.modelId = '',
    this.systemPrompt = '',
  })  : messages = messages ?? [],
        updatedAt = updatedAt ?? DateTime.now();

  void autoTitle() {
    if (title.isEmpty && messages.isNotEmpty) {
      final first = messages.first.content;
      title = first.length > 25 ? '${first.substring(0, 22)}...' : first;
    }
  }
}

@HiveType(typeId: 3)
enum MessageRole {
  @HiveField(0)
  system,
  @HiveField(1)
  user,
  @HiveField(2)
  assistant
}
