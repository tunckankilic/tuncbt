import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/models/chat_group.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/chat/chat_controller.dart';
import 'package:tuncbt/view/screens/chat/widgets/bottom_chat_field.dart';
import 'package:tuncbt/view/screens/chat/widgets/chat_list.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GroupChatScreen extends StatelessWidget {
  final ChatGroup group;

  const GroupChatScreen({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: group.imageUrl.isNotEmpty
                  ? CachedNetworkImageProvider(group.imageUrl)
                  : null,
              child: group.imageUrl.isEmpty
                  ? const Icon(Icons.group, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    AppLocalizations.of(context)!
                        .memberCount(group.members.length),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement group settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(
              receiverUserId: group.id,
              isGroupChat: true,
              messages: chatController.getGroupMessages(group.id),
            ),
          ),
          BottomChatField(
            receiverUserId: group.id,
            isGroupChat: true,
          ),
        ],
      ),
    );
  }
}
