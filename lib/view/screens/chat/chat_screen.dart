// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/view/screens/chat/chat_controller.dart';
import 'package:tuncbt/view/screens/chat/widgets/bottom_chat_field.dart';
import 'package:tuncbt/view/screens/chat/widgets/chat_list.dart';

class ChatScreen extends GetView<ChatController> {
  static String routeName = "/chatScreen";
  final UserModel receiver;
  const ChatScreen({
    required this.receiver,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(receiver.name),
            Obx(() => Text(
                  receiver.isOnline ? 'Online' : 'Offline',
                  style: const TextStyle(fontSize: 12),
                )),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundImage: NetworkImage(receiver.userImage),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(
              receiverUserId: receiver.id,
              isGroupChat: false,
            ),
          ),
          BottomChatField(
            receiverUserId: receiver.id,
            isGroupChat: false,
          ),
        ],
      ),
    );
  }
}
