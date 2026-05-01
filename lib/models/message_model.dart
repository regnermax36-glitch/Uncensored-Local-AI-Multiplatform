import 'package:hive/hive.dart';
import 'package:llamadart/llamadart.dart';
import 'chat_model.dart';

part 'message_model.g.dart';

@HiveType(typeId: 2)
class MessageModel {
  @HiveField(0)
  final MessageRole role;
  @HiveField(1)
  String content;
  @HiveField(2)
  final DateTime timestamp;

  MessageModel({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == MessageRole.user;
  bool get isSystem => role == MessageRole.system;

  LlamaChatMessage toLlamaMessage() {
    return LlamaChatMessage.fromText(
      role: isUser ? LlamaChatRole.user : (isSystem ? LlamaChatRole.system : LlamaChatRole.assistant),
      text: content,
    );
  }
}
