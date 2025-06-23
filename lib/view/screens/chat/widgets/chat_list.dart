import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tuncbt/core/models/message.dart';
import 'package:tuncbt/view/screens/chat/chat_controller.dart';
import 'package:tuncbt/view/screens/chat/widgets/my_message_card.dart';
import 'package:tuncbt/view/screens/chat/widgets/sender_message_card.dart';

class ChatList extends GetView<ChatController> {
  final String receiverUserId;
  final bool isGroupChat;

  const ChatList({
    Key? key,
    required this.receiverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: controller.getChatStream(receiverUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }

        final messages = snapshot.data!;

        return ListView.builder(
          controller: controller.scrollController,
          itemCount: messages.length,
          padding: const EdgeInsets.only(bottom: 16),
          itemBuilder: (context, index) {
            final messageData = messages[index];
            final timeSent = DateFormat.Hm().format(messageData.timestamp);
            final currentUserId = FirebaseAuth.instance.currentUser?.uid;

            if (!messageData.isRead &&
                messageData.receiverId == currentUserId) {
              controller.setMessageSeen(receiverUserId, messageData.messageId);
            }

            final isMyMessage = messageData.senderId == currentUserId;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: isMyMessage
                  ? MyMessageCard(
                      message: messageData.content,
                      date: timeSent,
                      type: messageData.type,
                      mediaUrl: messageData.mediaUrl,
                      replyTo: messageData.replyTo,
                      repliedTo: messageData.repliedTo,
                      repliedMessageType: messageData.repliedMessageType,
                      onLeftSwipe: () => controller.onMessageSwipe(
                        messageData.content,
                        true,
                        messageData.type,
                        mediaUrl: messageData.mediaUrl,
                        repliedTo: messageData.repliedTo,
                        repliedMessageType: messageData.repliedMessageType,
                      ),
                      isSeen: messageData.isRead,
                    )
                  : SenderMessageCard(
                      message: messageData.content,
                      date: timeSent,
                      type: messageData.type,
                      mediaUrl: messageData.mediaUrl,
                      replyTo: messageData.replyTo,
                      repliedTo: messageData.repliedTo,
                      repliedMessageType: messageData.repliedMessageType,
                      onRightSwipe: () => controller.onMessageSwipe(
                        messageData.content,
                        false,
                        messageData.type,
                        mediaUrl: messageData.mediaUrl,
                        repliedTo: messageData.repliedTo,
                        repliedMessageType: messageData.repliedMessageType,
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}
