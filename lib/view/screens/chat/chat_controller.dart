import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuncbt/core/enums/message_enum.dart';
import 'package:tuncbt/core/models/group.dart';
import 'package:tuncbt/core/models/message.dart';
import 'package:tuncbt/core/models/message_model.dart';
import 'package:tuncbt/core/models/message_reply.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  // Observable variables
  final isShowSendButton = false.obs;
  final isShowEmojiContainer = false.obs;
  final isRecording = false.obs;
  final isRecorderInit = false.obs;
  final messageReply = Rxn<MessageReply>();
  final messages = <Message>[].obs;
  final groups = <Group>[].obs;

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late FlutterSoundRecorder soundRecorder;

  @override
  void onInit() {
    super.onInit();
    soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  Future<void> openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic permission not allowed!');
    }
    await soundRecorder.openRecorder();
    isRecorderInit.value = true;
  }

  Future<UserModel?> getUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userData =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userData.exists) return null;

      return UserModel.fromFirestore(userData);
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Stream<List<Message>> getChatStream(String receiverUserId) {
    final chatRoomId = getChatRoomId(_auth.currentUser!.uid, receiverUserId);
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
    });
  }

  Stream<List<Message>> getGroupChatStream(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
    });
  }

  Future<void> sendTextMessage(
    BuildContext context,
    String receiverUserId,
    bool isGroupChat,
  ) async {
    try {
      if (isShowSendButton.value) {
        final currentUser = await getUserData();
        if (currentUser == null) return;

        final messageId = _uuid.v4();
        final timestamp = DateTime.now();
        final chatRoomId =
            getChatRoomId(_auth.currentUser!.uid, receiverUserId);

        final message = MessageModel(
          id: messageId,
          senderId: _auth.currentUser!.uid,
          receiverId: receiverUserId,
          content: messageController.text.trim(),
          timestamp: timestamp,
          isRead: false,
          type: MessageType.text,
          replyTo: messageReply.value?.message,
        );

        if (isGroupChat) {
          await _sendGroupMessage(receiverUserId, message);
        } else {
          await _sendDirectMessage(chatRoomId, message);
        }

        messageController.clear();
        messageReply.value = null;
        isShowSendButton.value = false;
      } else {
        // Handle voice recording
        var tempDir = await getTemporaryDirectory();
        var path = '${tempDir.path}/flutter_sound.aac';

        if (!isRecorderInit.value) return;

        if (isRecording.value) {
          await soundRecorder.stopRecorder();
          await sendFileMessage(
            context,
            File(path),
            receiverUserId,
            MessageEnum.audio,
            isGroupChat,
          );
        } else {
          await soundRecorder.startRecorder(toFile: path);
        }
        isRecording.toggle();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    }
  }

  Future<void> sendFileMessage(
    BuildContext context,
    File file,
    String receiverUserId,
    MessageEnum messageEnum,
    bool isGroupChat,
  ) async {
    try {
      final currentUser = await getUserData();
      if (currentUser == null) return;

      final messageId = _uuid.v4();
      final timestamp = DateTime.now();
      final chatRoomId = getChatRoomId(_auth.currentUser!.uid, receiverUserId);

      final mediaUrl = await _uploadFile(file, messageEnum, messageId);

      final message = MessageModel(
        id: messageId,
        senderId: _auth.currentUser!.uid,
        receiverId: receiverUserId,
        content: '',
        mediaUrl: mediaUrl,
        timestamp: timestamp,
        isRead: false,
        type: _convertMessageEnum(messageEnum),
        replyTo: messageReply.value?.message,
      );

      if (isGroupChat) {
        await _sendGroupMessage(receiverUserId, message);
      } else {
        await _sendDirectMessage(chatRoomId, message);
      }

      messageReply.value = null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to send file: $e');
    }
  }

  Future<void> sendGIFMessage(
    BuildContext context,
    String gifUrl,
    String receiverUserId,
    bool isGroupChat,
  ) async {
    try {
      final currentUser = await getUserData();
      if (currentUser == null) return;

      int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
      String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
      String newgifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';

      final messageId = _uuid.v4();
      final timestamp = DateTime.now();
      final chatRoomId = getChatRoomId(_auth.currentUser!.uid, receiverUserId);

      final message = MessageModel(
        id: messageId,
        senderId: _auth.currentUser!.uid,
        receiverId: receiverUserId,
        content: newgifUrl,
        timestamp: timestamp,
        isRead: false,
        type: MessageType.gif,
        replyTo: messageReply.value?.message,
      );

      if (isGroupChat) {
        await _sendGroupMessage(receiverUserId, message);
      } else {
        await _sendDirectMessage(chatRoomId, message);
      }

      messageReply.value = null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to send GIF: $e');
    }
  }

  // Private helper methods
  Future<String> _uploadFile(
      File file, MessageEnum type, String messageId) async {
    final fileRef = _storage
        .ref()
        .child('chat_media')
        .child(type.toString())
        .child(messageId);
    await fileRef.putFile(file);
    return await fileRef.getDownloadURL();
  }

  Future<void> _sendDirectMessage(
      String chatRoomId, MessageModel message) async {
    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc(message.id)
        .set(message.toFirestore());
    await _updateLastMessage(chatRoomId, message);
  }

  Future<void> _sendGroupMessage(String groupId, MessageModel message) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(message.id)
        .set(message.toFirestore());
    await _updateLastMessage(groupId, message, isGroupChat: true);
  }

  Future<void> _updateLastMessage(String chatRoomId, MessageModel message,
      {bool isGroupChat = false}) async {
    try {
      if (isGroupChat) {
        await _firestore.collection('groups').doc(chatRoomId).update({
          'lastMessage': message.content,
          'lastMessageTime': message.timestamp,
          'lastMessageType': message.type.toString(),
          'lastMessageSenderId': message.senderId,
        });
      } else {
        final currentUserId = _auth.currentUser!.uid;

        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('chats')
            .doc(message.receiverId)
            .set({
          'lastMessage': message.content,
          'lastMessageTime': message.timestamp,
          'lastMessageType': message.type.toString(),
          'unreadCount': 0,
        }, SetOptions(merge: true));

        await _firestore
            .collection('users')
            .doc(message.receiverId)
            .collection('chats')
            .doc(currentUserId)
            .set({
          'lastMessage': message.content,
          'lastMessageTime': message.timestamp,
          'lastMessageType': message.type.toString(),
          'unreadCount': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating last message: $e');
      rethrow;
    }
  }

  MessageType _convertMessageEnum(MessageEnum messageEnum) {
    switch (messageEnum) {
      case MessageEnum.image:
        return MessageType.image;
      case MessageEnum.video:
        return MessageType.video;
      case MessageEnum.audio:
        return MessageType.audio;
      default:
        return MessageType.text;
    }
  }

  // UI Helper methods
  void onMessageSwipe(String message, bool isMe, MessageEnum messageEnum) {
    messageReply.value = MessageReply(message, isMe, messageEnum);
  }

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer.value) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  void showEmojiContainer() => isShowEmojiContainer.value = true;
  void hideEmojiContainer() => isShowEmojiContainer.value = false;
  void showKeyboard() => Get.focusScope?.requestFocus();
  void hideKeyboard() => Get.focusScope?.unfocus();

  void onMessageChanged(String value) {
    isShowSendButton.value = value.isNotEmpty;
  }

  String getChatRoomId(String user1Id, String user2Id) {
    final sortedIds = [user1Id, user2Id]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  Future<void> markMessageAsRead(String messageId, String chatRoomId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    soundRecorder.closeRecorder();
    super.onClose();
  }
}
