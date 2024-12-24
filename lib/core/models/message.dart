import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncbt/core/enums/message_enum.dart';

class Message {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content; // text içeriği
  final DateTime timestamp; // timeSent yerine timestamp
  final bool isRead; // isSeen yerine isRead
  final MessageType type;
  final String? replyTo; // repliedMessage yerine replyTo
  final String? repliedTo; // kime yanıt verildiği
  final MessageType? repliedMessageType;
  final String? mediaUrl; // medya içeriği için

  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.replyTo,
    this.repliedTo,
    this.repliedMessageType,
    this.mediaUrl,
  });

  // JSON'dan Message oluşturma
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      isRead: json['isRead'] ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      replyTo: json['replyTo'],
      repliedTo: json['repliedTo'],
      repliedMessageType: json['repliedMessageType'] != null
          ? MessageType.values.firstWhere(
              (e) =>
                  e.toString() == 'MessageType.${json['repliedMessageType']}',
              orElse: () => MessageType.text,
            )
          : null,
      mediaUrl: json['mediaUrl'],
    );
  }

  // Firebase'den Message oluşturma
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message.fromJson({
      ...data,
      'messageId': doc.id,
    });
  }

  // Message'ı JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type.toString().split('.').last,
      'replyTo': replyTo,
      'repliedTo': repliedTo,
      'repliedMessageType': repliedMessageType?.toString().split('.').last,
      'mediaUrl': mediaUrl,
    };
  }
}
