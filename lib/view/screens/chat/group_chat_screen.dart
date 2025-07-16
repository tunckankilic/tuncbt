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
  late final ChatController chatController;

  GroupChatScreen({Key? key, required this.group}) : super(key: key) {
    chatController = Get.find<ChatController>();
  }

  @override
  Widget build(BuildContext context) {
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
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100, 0, 0, 0),
                items: [
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.group),
                      title: Text(AppLocalizations.of(context)!.groupMembers),
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/group-members', arguments: group);
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.exit_to_app),
                      title: Text(AppLocalizations.of(context)!.leaveTeam),
                      onTap: () {
                        Navigator.pop(context);
                        _showLeaveGroupDialog(context);
                      },
                    ),
                  ),
                ],
              );
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

  void _showLeaveGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.leaveTeam),
        content: Text(AppLocalizations.of(context)!.leaveTeamConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await chatController.leaveGroup(group.id);
                Navigator.pop(context); // Dialog'u kapat
                Navigator.pop(context); // Grup ekranını kapat
                Get.snackbar(
                  AppLocalizations.of(context)!.success,
                  AppLocalizations.of(context)!.leaveGroupSuccess,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Navigator.pop(context);
                Get.snackbar(
                  AppLocalizations.of(context)!.error,
                  AppLocalizations.of(context)!.leaveGroupError,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.leave),
          ),
        ],
      ),
    );
  }
}
