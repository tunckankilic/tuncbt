import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/models/chat_group.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/chat/chat_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GroupMembersScreen extends StatelessWidget {
  static const routeName = '/group-members';
  final ChatGroup group = Get.arguments;
  final chatController = Get.find<ChatController>();

  GroupMembersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.groupMembers),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: chatController.getGroupMembers(group.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(AppLocalizations.of(context)!.error),
            );
          }

          final members = snapshot.data ?? [];
          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: member.imageUrl.isNotEmpty
                      ? CachedNetworkImageProvider(member.imageUrl)
                      : null,
                  child:
                      member.imageUrl.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(member.name),
                subtitle: Text(member.position),
              );
            },
          );
        },
      ),
    );
  }
}
