import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
      stream: controller.getChatStream(receiverUserId, isGroupChat),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }

        SchedulerBinding.instance.addPostFrameCallback((_) {
          controller.scrollController
              .jumpTo(controller.scrollController.position.maxScrollExtent);
        });

        return ListView.builder(
          controller: controller.scrollController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final messageData = snapshot.data![index];
            var timeSent = DateFormat.Hm().format(messageData.timeSent);

            if (!messageData.isSeen &&
                messageData.receiverId ==
                    FirebaseAuth.instance.currentUser!.uid) {
              controller.setMessageSeen(
                receiverUserId,
                messageData.messageId,
              );
            }

            if (messageData.senderId ==
                FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: messageData.text,
                date: timeSent,
                type: messageData.type,
                repliedText: messageData.repliedMessage,
                username: messageData.repliedTo,
                repliedMessageType: messageData.repliedMessageType,
                onLeftSwipe: () => controller.onMessageSwipe(
                  messageData.text,
                  true,
                  messageData.type,
                ),
                isSeen: messageData.isSeen,
              );
            }

            return SenderMessageCard(
              message: messageData.text,
              date: timeSent,
              type: messageData.type,
              username: messageData.repliedTo,
              repliedMessageType: messageData.repliedMessageType,
              onRightSwipe: () => controller.onMessageSwipe(
                messageData.text,
                false,
                messageData.type,
              ),
              repliedText: messageData.repliedMessage,
            );
          },
        );
      },
    );
  }
}
