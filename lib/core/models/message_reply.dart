import 'package:tuncbt/core/enums/message_enum.dart';

class MessageReply {
  final String message;
  final bool isMe;
  final MessageType messageEnum;
  final String? mediaUrl;
  final String? repliedTo; // repliedTo alanı eklendi
  final MessageType? repliedMessageType; // repliedMessageType alanı eklendi

  MessageReply(
    this.message,
    this.isMe,
    this.messageEnum, {
    this.mediaUrl,
    this.repliedTo,
    this.repliedMessageType,
  });
}
