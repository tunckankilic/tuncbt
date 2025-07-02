import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncbt/core/enums/message_enum.dart';

class Message {
  final String messageId;
  final String senderId;
  final String? receiverId;
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
    this.receiverId,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.isRead,
    this.replyTo,
    this.repliedTo,
    this.repliedMessageType,
    this.mediaUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.toString(),
      'isRead': isRead,
      'replyTo': replyTo,
      'repliedTo': repliedTo,
      'repliedMessageType': repliedMessageType?.toString(),
      'mediaUrl': mediaUrl,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'],
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => MessageType.text,
      ),
      isRead: map['isRead'] ?? false,
      replyTo: map['replyTo'],
      repliedTo: map['repliedTo'],
      repliedMessageType: map['repliedMessageType'] != null
          ? MessageType.values.firstWhere(
              (e) => e.toString() == map['repliedMessageType'],
              orElse: () => MessageType.text,
            )
          : null,
      mediaUrl: map['mediaUrl'],
    );
  }

  Map<String, dynamic> toJson() => toMap();

  // Firebase'den Message oluşturma
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message.fromMap({
      ...data,
      'messageId': doc.id,
    });
  }
}
