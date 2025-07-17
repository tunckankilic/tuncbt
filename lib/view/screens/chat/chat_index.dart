import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/chat/chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tuncbt/view/screens/chat/chat_controller.dart';
import 'package:tuncbt/view/screens/chat/chat_bindings.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.messages),
      ),
      body: _buildChatsTab(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
              .where(FieldPath.documentId, isNotEqualTo: currentUser.uid)
              .get();

          if (!context.mounted) return;

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.newChat),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: teamMembers.docs.length,
                  itemBuilder: (context, index) {
                    final member =
                        UserModel.fromFirestore(teamMembers.docs[index]);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        backgroundImage: member.imageUrl.isNotEmpty
                            ? CachedNetworkImageProvider(member.imageUrl)
                            : null,
                        child: member.imageUrl.isEmpty
                            ? const Icon(Icons.person, color: Colors.grey)
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
            ),
          );
        },
        child: const Icon(Icons.message),
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

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    backgroundImage: user.imageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(user.imageUrl)
                        : null,
                    child: user.imageUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  title: Text(user.name),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMessageTime != null)
                        Text(
                          timeago.format(lastMessageTime, locale: 'tr'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                    ],
                  ),
                  onTap: () {
                    _markAsRead(otherUserId);
                    Get.to(
                      () => ChatScreen(receiver: user),
                      binding: ChatBindings(),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
