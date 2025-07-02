import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/core/models/chat_group.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/chat/chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tuncbt/view/screens/chat/chat_controller.dart';
import 'package:tuncbt/view/screens/chat/chat_bindings.dart';
import 'package:tuncbt/view/screens/chat/create_group_screen.dart';
import 'package:tuncbt/view/screens/chat/group_chat_screen.dart';

class ChatIndexScreen extends StatelessWidget {
  static const routeName = '/chat-index';

  const ChatIndexScreen({Key? key}) : super(key: key);

  Future<void> _markAsRead(String otherUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(otherUserId)
          .update({
        'unreadCount': 0,
      });
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  void _showUserOptions(BuildContext context, UserModel user) async {
    final chatController = Get.find<ChatController>();
    final isBlocked = await chatController.isUserBlocked(user.id);

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.block),
            title: Text(isBlocked ? 'Engeli Kaldır' : 'Engelle'),
            onTap: () {
              Navigator.pop(context);
              if (isBlocked) {
                chatController.unblockUser(user.id);
              } else {
                chatController.blockUser(user.id);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Sohbeti Sil'),
            onTap: () async {
              Navigator.pop(context);
              // Onay dialog'u göster
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.deleteChat),
                  content:
                      Text(AppLocalizations.of(context)!.deleteChatConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        AppLocalizations.of(context)!.delete,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                if (currentUserId != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUserId)
                      .collection('chats')
                      .doc(user.id)
                      .delete();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.chats),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: AppLocalizations.of(context)!.chats),
                Tab(text: AppLocalizations.of(context)!.groups),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildChatsTab(),
                  _buildGroupsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(AppLocalizations.of(context)!.newChat),
                  onTap: () async {
                    Navigator.pop(context);
                    // Takım üyelerini getir ve sohbet başlat
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) return;

                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .get();

                    if (!userDoc.exists) return;

                    final userData = UserModel.fromFirestore(userDoc);
                    if (userData.teamId == null) return;

                    // Takım üyelerini listele
                    final teamMembers = await FirebaseFirestore.instance
                        .collection('users')
                        .where('teamId', isEqualTo: userData.teamId)
                        .where(FieldPath.documentId,
                            isNotEqualTo: currentUser.uid)
                        .get();

                    if (!context.mounted) return;

                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Yeni Sohbet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: teamMembers.docs.length,
                              itemBuilder: (context, index) {
                                final member = UserModel.fromFirestore(
                                    teamMembers.docs[index]);
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: member.imageUrl.isNotEmpty
                                        ? CachedNetworkImageProvider(
                                            member.imageUrl)
                                        : null,
                                    child: member.imageUrl.isEmpty
                                        ? const Icon(Icons.person,
                                            color: Colors.grey)
                                        : null,
                                  ),
                                  title: Text(member.name),
                                  subtitle: Text(member.position),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Get.to(
                                      () => ChatScreen(receiver: member),
                                      binding: ChatBindings(),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group_add),
                  title: Text(AppLocalizations.of(context)!.newGroup),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(CreateGroupScreen.routeName);
                  },
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChatsTab() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noChats,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final chatDoc = snapshot.data!.docs[index];
            final chatData = chatDoc.data() as Map<String, dynamic>;
            final otherUserId = chatDoc.id;
            final unreadCount = chatData['unreadCount'] as int? ?? 0;
            final lastMessage = chatData['lastMessage'] as String? ?? '';
            final lastMessageTime =
                (chatData['lastMessageTime'] as Timestamp?)?.toDate();

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const SizedBox();
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final user = UserModel.fromFirestore(userSnapshot.data!);

                return Dismissible(
                  key: Key(otherUserId),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.deleteChat),
                        content: Text(
                            AppLocalizations.of(context)!.deleteChatConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              AppLocalizations.of(context)!.delete,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUserId)
                        .collection('chats')
                        .doc(otherUserId)
                        .delete();
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      backgroundImage: user.imageUrl.isNotEmpty
                          ? CachedNetworkImageProvider(user.imageUrl)
                          : null,
                      child: user.imageUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  unreadCount > 0 ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        if (lastMessageTime != null)
                          Text(
                            timeago.format(lastMessageTime,
                                locale:
                                    AppLocalizations.of(context)!.localeName),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  unreadCount > 0 ? Colors.black : Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showUserOptions(context, user),
                        ),
                      ],
                    ),
                    onTap: () {
                      _markAsRead(otherUserId);
                      Get.to(
                        () => ChatScreen(receiver: user),
                        binding: ChatBindings(),
                      );
                    },
                    onLongPress: () => _showUserOptions(context, user),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGroupsTab() {
    final chatController = Get.find<ChatController>();

    return StreamBuilder<List<ChatGroup>>(
      stream: chatController.getMyGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noGroups,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final group = snapshot.data![index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                backgroundImage: group.imageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(group.imageUrl)
                    : null,
                child: group.imageUrl.isEmpty
                    ? const Icon(Icons.group, color: Colors.grey)
                    : null,
              ),
              title: Text(
                group.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(context)!.memberCount(group.members.length),
                style: const TextStyle(color: Colors.grey),
              ),
              trailing:
                  group.unreadCounts[FirebaseAuth.instance.currentUser?.uid] !=
                              null &&
                          group.unreadCounts[
                                  FirebaseAuth.instance.currentUser?.uid]! >
                              0
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            group.unreadCounts[
                                    FirebaseAuth.instance.currentUser?.uid]
                                .toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : null,
              onTap: () {
                Get.to(
                  () => GroupChatScreen(group: group),
                  binding: ChatBindings(),
                );
              },
            );
          },
        );
      },
    );
  }
}
