import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuncbt/core/enums/message_enum.dart';
import 'package:tuncbt/core/models/group.dart';
import 'package:tuncbt/core/models/message.dart';
import 'package:tuncbt/core/models/message_reply.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuncbt/core/models/chat_group.dart';
import 'package:tuncbt/l10n/app_localizations.dart';

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
  final RxBool isReceiverOnline = false.obs;
  final Rx<UserModel?> receiver = Rx<UserModel?>(null);
  final RxBool isSending = false.obs;
  final RxString recordDuration = '00:00'.obs;
  final RxBool isRecordingPulsing = false.obs;
  final RxBool isPickingFile = false.obs;

  // Stream subscription for user status
  StreamSubscription? _userStatusSubscription;

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late FlutterSoundRecorder soundRecorder;
  Timer? _recordingTimer;
  DateTime? _recordingStartTime;

  @override
  void onInit() {
    super.onInit();
    soundRecorder = FlutterSoundRecorder();
    _initAudio();
    updateUserStatus(true);

    // Receiver değiştiğinde mesajları okundu olarak işaretle
    ever(receiver, (UserModel? user) {
      if (user != null) {
        markAllMessagesAsRead(user.id);
      }
    });
  }

  Future<bool> showPermissionRationale() async {
    final context = Get.context!;
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(AppLocalizations.of(context)!.micPermissionTitle),
        content: Text(AppLocalizations.of(context)!.micPermissionMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(AppLocalizations.of(context)!.notNow),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(AppLocalizations.of(context)!.continueAction),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  void _showOpenSettingsDialog() {
    final context = Get.context!;
    Get.dialog(
      AlertDialog(
        title: Text(AppLocalizations.of(context)!.permissionRequired),
        content:
            Text(AppLocalizations.of(context)!.micPermissionSettingsMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: Text(AppLocalizations.of(context)!.openSettings),
          ),
        ],
      ),
    );
  }

  void _startRecordingTimer() {
    _recordingStartTime = DateTime.now();
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_recordingStartTime != null) {
        final duration = DateTime.now().difference(_recordingStartTime!);
        final minutes = (duration.inSeconds ~/ 60).toString().padLeft(2, '0');
        final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
        recordDuration.value = '$minutes:$seconds';
      }
    });
    // Başlat pulsing animasyonu
    isRecordingPulsing.value = true;
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _recordingStartTime = null;
    recordDuration.value = '00:00';
    isRecordingPulsing.value = false;
  }

  // Ses kaydını başlat
  Future<void> startRecording() async {
    try {
      // Mikrofon iznini kontrol et
      final status = await Permission.microphone.status;

      if (status.isDenied) {
        // İzin henüz istenmemiş, kullanıcıya açıklama göster
        final showRationale = await showPermissionRationale();
        if (!showRationale) return;

        // İzni iste
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          if (result.isPermanentlyDenied) {
            _showOpenSettingsDialog();
          }
          return;
        }
      } else if (status.isPermanentlyDenied) {
        _showOpenSettingsDialog();
        return;
      } else if (!status.isGranted) {
        return;
      }

      // Kaydedici başlatılmamışsa başlat
      if (!isRecorderInit.value) {
        await soundRecorder.openRecorder();
        isRecorderInit.value = true;
      }

      // Geçici dosya yolu oluştur
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      // Kaydı başlat
      await soundRecorder.startRecorder(toFile: filePath);
      isRecording.value = true;
      _startRecordingTimer();
    } catch (e) {
      print('Recording error: $e');
      Get.snackbar(
        AppLocalizations.of(Get.context!)!.recordingError,
        AppLocalizations.of(Get.context!)!.recordingStartError,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  // Ses kaydını durdur
  Future<String?> stopRecording() async {
    if (!isRecording.value) return null;

    try {
      _stopRecordingTimer();
      final filePath = await soundRecorder.stopRecorder();
      isRecording.value = false;
      return filePath;
    } catch (e) {
      print('Stop recording error: $e');
      Get.snackbar(
        AppLocalizations.of(Get.context!)!.recordingError,
        AppLocalizations.of(Get.context!)!.recordingStopError,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
      return null;
    }
  }

  Future<void> _initAudio() async {
    try {
      final status = await Permission.microphone.status;
      if (status.isGranted) {
        await soundRecorder.openRecorder();
        isRecorderInit.value = true;
      }
    } catch (e) {
      print('Audio initialization error: $e');
    }
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

  // ScrollController'ı sıfırlama metodu
  void resetScroll() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Yeni mesaj geldiğinde scroll'u en alta kaydır
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void initializeReceiver(UserModel receiverUser) {
    receiver.value = receiverUser;

    // Online durumunu dinlemeye başla
    _userStatusSubscription = _firestore
        .collection('users')
        .doc(receiverUser.id)
        .snapshots()
        .listen((documentSnapshot) {
      if (documentSnapshot.exists) {
        // Firestore'dan gelen verileri al
        final userData = documentSnapshot.data() as Map<String, dynamic>;

        // Online durumunu güncelle
        isReceiverOnline.value = userData['isOnline'] ?? false;

        // Son görülme zamanını kontrol et
        final lastSeen = userData['lastSeen'] as Timestamp?;
        if (lastSeen != null) {
          final lastSeenTime = lastSeen.toDate();
          final currentTime = DateTime.now();

          // Eğer son görülme 5 dakikadan eskiyse offline say
          if (currentTime.difference(lastSeenTime).inMinutes > 5) {
            isReceiverOnline.value = false;
          }
        }
      }
    });
  }

  // Kullanıcı durumunu güncelle
  Future<void> updateUserStatus(bool isOnline) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore.collection('users').doc(currentUser.uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user status: $e');
    }
  }

  Stream<List<Message>> getChatStream(String receiverId) {
    final chatRoomId = getChatRoomId(receiverId);
    print('ChatRoomId: $chatRoomId'); // Debug için

    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      print('Snapshot data: ${snapshot.docs.length}'); // Debug için
      return snapshot.docs.map((doc) {
        final data = doc.data();
        print('Message data: $data'); // Debug için
        return Message.fromMap(data);
      }).toList();
    });
  }

  String getChatRoomId(String receiverId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || receiverId.isEmpty) {
      print('Invalid user IDs for chat room');
      return '';
    }

    // ID'leri sırala ve birleştir
    final users = [currentUserId, receiverId];
    users.sort();
    final chatRoomId = users.join('_');

    print('Generated chat room ID: $chatRoomId'); // Debug için
    return chatRoomId;
  }

  Stream<List<Message>> getGroupChatStream(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
    });
  }

  Future<void> sendTextMessage(
    BuildContext context,
    String receiverUserId,
    bool isGroupChat,
  ) async {
    try {
      // 1. Input kontrolü
      final messageText = messageController.text.trim();
      if (messageText.isEmpty) {
        print('Message text is empty');
        return;
      }

      // 2. Kullanıcı kontrolü
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        print('Current user is null');
        throw Exception(AppLocalizations.of(context)!.sessionExpired);
      }

      // 3. Chat ID oluşturma
      final messageId = _uuid.v4();
      final timestamp = DateTime.now();
      final chatRoomId = getChatRoomId(receiverUserId);

      print('Debug info:');
      print('Message ID: $messageId');
      print('Chat Room ID: $chatRoomId');
      print('Current User ID: $currentUserId');
      print('Receiver ID: $receiverUserId');

      // 4. Message oluşturma
      final message = Message(
        messageId: messageId,
        senderId: currentUserId,
        receiverId: receiverUserId,
        content: messageText,
        timestamp: timestamp,
        type: MessageType.text,
        isRead: false,
        replyTo: messageReply.value?.message,
        repliedTo: messageReply.value?.repliedTo,
        repliedMessageType: messageReply.value?.messageEnum,
        mediaUrl: messageReply.value?.mediaUrl,
      );

      // 5. Mesajı gönderme
      if (isGroupChat) {
        await _sendGroupMessage(receiverUserId, message);
      } else {
        await _firestore
            .collection('chats')
            .doc(chatRoomId)
            .collection('messages')
            .doc(messageId)
            .set(message.toJson());

        // 6. Son mesaj bilgisini güncelle
        await _updateLastMessage(chatRoomId, message);
      }

      // 7. Input temizleme ve reply sıfırlama
      messageController.clear();
      messageReply.value = null;

      print('Message sent successfully');
    } catch (e, stackTrace) {
      print('Error sending message: $e');
      print('Stack trace: $stackTrace');

      String errorMessage = AppLocalizations.of(context)!.failedToSendMessage;
      if (e is FirebaseException) {
        errorMessage = _getFirebaseErrorMessage(context, e.code);
      }

      Get.snackbar(
        AppLocalizations.of(context)!.errorTitleChat,
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  String _getFirebaseErrorMessage(BuildContext context, String code) {
    switch (code) {
      case 'permission-denied':
        return AppLocalizations.of(context)!.noPermissionToSendMessage;
      case 'not-found':
        return AppLocalizations.of(context)!.chatRoomNotFound;
      case 'network-request-failed':
        return AppLocalizations.of(context)!.networkError;
      default:
        return AppLocalizations.of(context)!.failedToSendMessage;
    }
  }

  Future<void> _sendGroupMessage(String groupId, Message message) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(message.messageId)
        .set(message.toJson()); // toFirestore yerine toJson

    await _updateLastMessage(
      groupId,
      message,
    );
  }

  Future<void> _updateLastMessage(String chatRoomId, Message message) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        print('Current user is null in _updateLastMessage');
        return;
      }

      print('Updating last message for chat room: $chatRoomId');
      print('Sender ID: $currentUserId');
      print('Receiver ID: ${message.receiverId}');

      // Gönderen için güncelle
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(message.receiverId)
          .set({
        'lastMessage': message.content,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
        'lastMessageType': message.type.toString().split('.').last,
        'unreadCount': 0,
      }, SetOptions(merge: true));

      // Alıcı için güncelle
      await _firestore
          .collection('users')
          .doc(message.receiverId)
          .collection('chats')
          .doc(currentUserId)
          .set({
        'lastMessage': message.content,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
        'lastMessageType': message.type.toString().split('.').last,
        'unreadCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      print('Last message updated successfully');
    } catch (e) {
      print('Error updating last message: $e');
      rethrow; // Ana fonksiyonda yakalanması için hatayı yeniden fırlat
    }
  }

  Future<void> setMessageSeen(String receiverUserId, String messageId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        print('User not authenticated');
        return;
      }

      // ChatRoomId oluştururken receiverUserId'yi parametre olarak geçiriyoruz
      final chatRoomId = getChatRoomId(receiverUserId);
      if (chatRoomId.isEmpty) {
        print('Invalid chat room ID');
        return;
      }

      // Mesajı görüldü olarak işaretle
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true}); // isSeen yerine isRead kullanıyoruz

      // Okunmamış mesaj sayısını sıfırla
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(receiverUserId)
          .set({
        'unreadCount': 0,
        'lastMessageRead': DateTime.now(),
      }, SetOptions(merge: true)); // update yerine set with merge kullanıyoruz

      print('Message marked as read successfully');
    } catch (e) {
      print('Error setting message seen status: $e');
      // Hata detaylarını logla
      if (e is FirebaseException) {
        print('Firebase error code: ${e.code}');
        print('Firebase error message: ${e.message}');
      }
    }
  }

  Future<void> markAllMessagesAsRead(String receiverUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Okunmamış mesaj sayısını sıfırla
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(receiverUserId)
          .set({
        'unreadCount': 0,
        'lastMessageRead': DateTime.now(),
      }, SetOptions(merge: true));

      // Tüm mesajları okundu olarak işaretle
      final chatRoomId = getChatRoomId(receiverUserId);
      final messages = await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('receiverId', isEqualTo: currentUserId)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      print('All messages marked as read');
    } catch (e) {
      print('Error marking all messages as read: $e');
    }
  }

  Future<void> sendFileMessage(
    BuildContext context,
    File file,
    String receiverUserId,
    MessageType messageEnum,
    bool isGroupChat,
  ) async {
    try {
      final currentUser = await getUserData();
      if (currentUser == null) return;

      final messageId = _uuid.v4();
      final timestamp = DateTime.now();
      final chatRoomId = getChatRoomId(receiverUserId);

      // Dosyayı yükle ve URL al
      String mediaUrl = await _uploadFile(file, messageEnum, messageId);

      // Mesaj modelini oluştur
      final message = Message(
        messageId: messageId,
        senderId: currentUser.id,
        receiverId: receiverUserId,
        content: '', // Medya mesajlarında content boş olabilir
        mediaUrl: mediaUrl, // Medya URL'ini ekle
        timestamp: timestamp,
        isRead: false,
        type: messageEnum,
        replyTo: messageReply.value?.message,
        repliedTo: messageReply.value?.repliedTo,
        repliedMessageType: messageReply.value?.repliedMessageType,
      );

      // Mesajı gönder
      if (isGroupChat) {
        await _sendGroupMessage(receiverUserId, message);
      } else {
        await _sendDirectMessage(chatRoomId, message);
      }

      // Reply durumunu sıfırla
      messageReply.value = null;
    } catch (e) {
      print('Error sending file message: $e');
      Get.snackbar(
        AppLocalizations.of(context)!.error,
        AppLocalizations.of(context)!.failedToSendFile,
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: const Duration(seconds: 3),
      );
    }
  }

// Medya yükleme fonksiyonu
  Future<String> _uploadFile(
      File file, MessageType type, String messageId) async {
    try {
      // Dosya uzantısını al
      final extension = file.path.split('.').last;

      // Storage referansını oluştur
      final fileRef = _storage
          .ref()
          .child('chat_media')
          .child(type
              .toString()
              .split('.')
              .last) // Klasör adı için enum değerini kullan
          .child('$messageId.$extension');

      // Dosyayı yükle
      await fileRef.putFile(file);

      // Download URL'ini al ve döndür
      return await fileRef.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  Future<void> sendGIFMessage(
    BuildContext context,
    String gifUrl,
    String receiverUserId,
  ) async {
    try {
      final currentUser = await getUserData();
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Giphy URL'den optimizasyon yapılmış URL'e çevir
      String optimizedGifUrl = '';
      if (gifUrl.contains('/media/')) {
        final mediaIndex = gifUrl.indexOf('/media/');
        if (mediaIndex != -1) {
          final idStart = mediaIndex + 7;
          final idEnd = gifUrl.indexOf('/', idStart);
          if (idEnd != -1) {
            final gifId = gifUrl.substring(idStart, idEnd);
            optimizedGifUrl = 'https://i.giphy.com/media/$gifId/200.gif';
          }
        }
      } else {
        final parts = gifUrl.split('-');
        if (parts.isNotEmpty) {
          final gifId = parts.last.split('/').first;
          optimizedGifUrl = 'https://i.giphy.com/media/$gifId/200.gif';
        }
      }

      // URL düzenlenemediyse orijinal URL'i kullan
      final finalGifUrl = optimizedGifUrl.isNotEmpty ? optimizedGifUrl : gifUrl;

      final messageId = _uuid.v4();
      final timestamp = DateTime.now();
      final chatRoomId = getChatRoomId(receiverUserId);

      final message = Message(
        messageId: messageId,
        senderId: currentUser.id,
        receiverId: receiverUserId,
        content: finalGifUrl,
        timestamp: timestamp,
        isRead: false,
        type: MessageType.gif,
        replyTo: messageReply.value?.message,
        repliedMessageType: messageReply.value?.messageEnum,
      );

      // Mesajı gönder
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .set(message.toJson());

      // Son mesaj bilgisini güncelle
      await _updateLastMessage(chatRoomId, message);

      // Reply bilgisini sıfırla
      messageReply.value = null;

      // Başarılı gönderim bildirimi (isteğe bağlı)
      Get.snackbar(
        AppLocalizations.of(context)!.success,
        AppLocalizations.of(context)!.gifSentSuccessfully,
        backgroundColor: Colors.green.withOpacity(0.1),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error sending GIF: $e'); // Hata ayıklama için
      Get.snackbar(
        AppLocalizations.of(context)!.error,
        AppLocalizations.of(context)!.failedToSendGIF,
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _sendDirectMessage(String chatRoomId, Message message) async {
    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc(message.messageId)
        .set(message.toJson()); // toFirestore yerine toJson kullan

    await _updateLastMessage(chatRoomId, message);
  }

  void onMessageSwipe(
    String message,
    bool isMe,
    MessageType messageEnum, {
    String? mediaUrl,
    String? repliedTo,
    MessageType? repliedMessageType,
  }) {
    print(
        'onMessageSwipe - Message: $message, MediaUrl: $mediaUrl, Type: $messageEnum');
    final replyMessage =
        messageEnum == MessageType.text ? message : (mediaUrl ?? message);

    messageReply.value = MessageReply(
      replyMessage,
      isMe,
      messageEnum,
      mediaUrl: mediaUrl,
      repliedTo: repliedTo,
      repliedMessageType: repliedMessageType,
    );
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
    if (value.isNotEmpty != isShowSendButton.value) {
      isShowSendButton.value = value.isNotEmpty;
    }
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

  Future<void> handleSendMessage(
      BuildContext context, String receiverUserId, bool isGroupChat) async {
    if (isSending.value) return;

    try {
      isSending.value = true;
      await sendTextMessage(context, receiverUserId, isGroupChat);
      messageController.clear();
      isShowSendButton.value = false;
    } finally {
      isSending.value = false;
    }
  }

  Future<void> handleRecordingStart() async {
    if (!isRecording.value) {
      await startRecording();
    }
  }

  Future<void> handleRecordingStop(
      BuildContext context, String receiverUserId, bool isGroupChat) async {
    if (isRecording.value) {
      final audioPath = await stopRecording();
      if (audioPath != null) {
        await sendFileMessage(
          context,
          File(audioPath),
          receiverUserId,
          MessageType.audio,
          isGroupChat,
        );
      }
    }
  }

  Future<void> handleRecordingCancel() async {
    if (isRecording.value) {
      await stopRecording();
    }
  }

  Future<void> pickAndSendFile(BuildContext context, String receiverUserId,
      bool isGroupChat, MessageType type) async {
    if (isPickingFile.value) return;

    try {
      isPickingFile.value = true;
      FilePickerResult? result;
      File? file;

      switch (type) {
        case MessageType.image:
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 70,
          );
          if (image != null) {
            file = File(image.path);
          }
          break;

        case MessageType.video:
          final ImagePicker picker = ImagePicker();
          final XFile? video = await picker.pickVideo(
            source: ImageSource.gallery,
          );
          if (video != null) {
            file = File(video.path);
          }
          break;

        case MessageType.audio:
          result = await FilePicker.platform.pickFiles(
            type: FileType.audio,
          );
          if (result != null && result.files.single.path != null) {
            file = File(result.files.single.path!);
          }
          break;

        default:
          break;
      }

      if (file != null) {
        await sendFileMessage(
          context,
          file,
          receiverUserId,
          type,
          isGroupChat,
        );
      }
    } catch (e) {
      print('Dosya seçme hatası: $e');
      Get.snackbar(
        AppLocalizations.of(context)!.error,
        AppLocalizations.of(context)!.filePickingError,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      isPickingFile.value = false;
    }
  }

  void showAttachmentOptions(
      BuildContext context, String receiverUserId, bool isGroupChat) {
    if (isPickingFile.value) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Color(0xFF128C7E)),
              title: Text(AppLocalizations.of(context)!.photo),
              onTap: () {
                Get.back();
                pickAndSendFile(
                    context, receiverUserId, isGroupChat, MessageType.image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFF128C7E)),
              title: Text(AppLocalizations.of(context)!.video),
              onTap: () {
                Get.back();
                pickAndSendFile(
                    context, receiverUserId, isGroupChat, MessageType.video);
              },
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<void> deleteMessage(String messageId, String receiverUserId) async {
    try {
      final chatRoomId = getChatRoomId(receiverUserId);
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();

      // Son mesajı güncelle
      final messages = await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (messages.docs.isNotEmpty) {
        final lastMessage = Message.fromMap(messages.docs.first.data());
        await _updateLastMessage(chatRoomId, lastMessage);
      }
    } catch (e) {
      print('Error deleting message: $e');
      Get.snackbar(
        AppLocalizations.of(Get.context!)!.error,
        AppLocalizations.of(Get.context!)!.messageDeletionError,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      // Engellenen kullanıcıyı kaydet
      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayUnion([userId]),
      });

      Get.snackbar(
        AppLocalizations.of(Get.context!)!.success,
        AppLocalizations.of(Get.context!)!.userBlocked,
        backgroundColor: Colors.green.withOpacity(0.1),
      );
    } catch (e) {
      print('Error blocking user: $e');
      Get.snackbar(
        AppLocalizations.of(Get.context!)!.error,
        AppLocalizations.of(Get.context!)!.userBlockError,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayRemove([userId]),
      });

      Get.snackbar(
        AppLocalizations.of(Get.context!)!.success,
        AppLocalizations.of(Get.context!)!.userUnblocked,
        backgroundColor: Colors.green.withOpacity(0.1),
      );
    } catch (e) {
      print('Error unblocking user: $e');
      Get.snackbar(
        AppLocalizations.of(Get.context!)!.error,
        AppLocalizations.of(Get.context!)!.userUnblockError,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  Future<bool> isUserBlocked(String userId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      final blockedUsers =
          List<String>.from(userDoc.data()?['blockedUsers'] ?? []);
      return blockedUsers.contains(userId);
    } catch (e) {
      print('Error checking blocked status: $e');
      return false;
    }
  }

  Future<List<UserModel>> getTeamMembers() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) return [];

      final userData = UserModel.fromFirestore(userDoc);
      if (userData.teamId == null) return [];

      final teamMembers = await _firestore
          .collection('users')
          .where('teamId', isEqualTo: userData.teamId)
          .where(FieldPath.documentId, isNotEqualTo: currentUser.uid)
          .get();

      return teamMembers.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting team members: $e');
      return [];
    }
  }

  Future<void> createGroup({
    required String name,
    required String description,
    required List<String> members,
    File? imageFile,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      String imageUrl = '';
      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = _storage.ref().child('group_images').child(fileName);
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      // Grup oluştur
      final groupRef = await _firestore.collection('chat_groups').add({
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'createdBy': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'members': [...members, currentUser.uid],
        'admins': [currentUser.uid],
        'unreadCounts': {},
      });

      // Grup sohbeti koleksiyonunu oluştur
      await _firestore.collection('group_chats').doc(groupRef.id).set({
        'lastMessage': 'Grup oluşturuldu',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageType': 'system',
      });

      print('Group created successfully');
    } catch (e) {
      print('Error creating group: $e');
      rethrow;
    }
  }

  Future<void> addMembersToGroup(
      String groupId, List<String> newMembers) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final groupDoc =
          await _firestore.collection('chat_groups').doc(groupId).get();
      if (!groupDoc.exists) return;

      final group = ChatGroup.fromFirestore(groupDoc);
      if (!group.isAdmin(currentUser.uid)) {
        throw Exception(AppLocalizations.of(Get.context!)!.onlyAdminsCanAdd);
      }

      await _firestore.collection('chat_groups').doc(groupId).update({
        'members': FieldValue.arrayUnion(newMembers),
      });

      // Sistem mesajı ekle
      await _firestore
          .collection('group_chats')
          .doc(groupId)
          .collection('messages')
          .add({
        'type': 'system',
        'content': 'Yeni üyeler eklendi',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Members added to group successfully');
    } catch (e) {
      print('Error adding members to group: $e');
      rethrow;
    }
  }

  Future<void> removeMemberFromGroup(String groupId, String memberId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception(AppLocalizations.of(Get.context!)!.sessionExpired);
      }

      final groupDoc =
          await _firestore.collection('chat_groups').doc(groupId).get();
      if (!groupDoc.exists) return;

      final group = ChatGroup.fromFirestore(groupDoc);
      if (!group.isAdmin(currentUser.uid)) {
        throw Exception(AppLocalizations.of(Get.context!)!.onlyAdminsCanRemove);
      }

      await _firestore.collection('chat_groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([memberId]),
        'admins': FieldValue.arrayRemove([memberId]),
      });

      // Sistem mesajı ekle
      await _firestore
          .collection('group_chats')
          .doc(groupId)
          .collection('messages')
          .add({
        'type': 'system',
        'content': 'Bir üye gruptan çıkarıldı',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Member removed from group successfully');
    } catch (e, stackTrace) {
      print('Error removing member from group: $e');
      print('Stack trace: $stackTrace');

      String errorMessage =
          AppLocalizations.of(Get.context!)!.failedToRemoveMember;
      if (e is FirebaseException) {
        errorMessage = _getFirebaseErrorMessage(Get.context!, e.code);
      }

      Get.snackbar(
        AppLocalizations.of(Get.context!)!.errorTitleGroup,
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  Future<void> makeGroupAdmin(String groupId, String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception(AppLocalizations.of(Get.context!)!.sessionExpired);
      }

      final groupDoc =
          await _firestore.collection('chat_groups').doc(groupId).get();
      if (!groupDoc.exists) return;

      final group = ChatGroup.fromFirestore(groupDoc);
      if (!group.isAdmin(currentUser.uid)) {
        throw Exception(
            AppLocalizations.of(Get.context!)!.onlyAdminsCanPromote);
      }

      await _firestore.collection('chat_groups').doc(groupId).update({
        'admins': FieldValue.arrayUnion([userId]),
      });

      // Sistem mesajı ekle
      await _firestore
          .collection('group_chats')
          .doc(groupId)
          .collection('messages')
          .add({
        'type': 'system',
        'content': 'Yeni grup admini atandı',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('User made group admin successfully');
    } catch (e, stackTrace) {
      print('Error making user group admin: $e');
      print('Stack trace: $stackTrace');

      String errorMessage =
          AppLocalizations.of(Get.context!)!.failedToPromoteAdmin;
      if (e is FirebaseException) {
        errorMessage = _getFirebaseErrorMessage(Get.context!, e.code);
      }

      Get.snackbar(
        AppLocalizations.of(Get.context!)!.errorTitleGroup,
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  Stream<List<ChatGroup>> getMyGroups() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('chat_groups')
        .where('members', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatGroup.fromFirestore(doc)).toList());
  }

  Stream<List<Message>> getGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((event) {
      return event.docs.map((e) => Message.fromMap(e.data())).toList();
    });
  }

  Future<void> sendGroupMessage(
    String groupId,
    String message,
    MessageType type,
  ) async {
    try {
      final timeSent = DateTime.now();
      final messageDoc = Message(
        messageId: _uuid.v4(),
        senderId: _auth.currentUser!.uid,
        content: message,
        timestamp: timeSent,
        type: type,
        isRead: false,
      );

      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .add(messageDoc.toMap());

      await _firestore.collection('groups').doc(groupId).update({
        'lastMessage': message,
        'lastMessageTime': timeSent,
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) throw 'User not authenticated';

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .update({
        'members': FieldValue.arrayRemove([currentUserId])
      });

      // Kullanıcının grup sohbetlerinden grubu sil
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('group_chats')
          .doc(groupId)
          .delete();
    } catch (e) {
      print('Error leaving group: $e');
      throw 'Failed to leave group';
    }
  }

  Future<List<UserModel>> getGroupMembers(String groupId) async {
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (!groupDoc.exists) throw 'Group not found';

      final List<String> memberIds =
          List<String>.from(groupDoc.data()!['members']);
      final List<UserModel> members = [];

      for (String memberId in memberIds) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();

        if (userDoc.exists) {
          members.add(UserModel.fromFirestore(userDoc));
        }
      }

      return members;
    } catch (e) {
      print('Error getting group members: $e');
      return [];
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    _userStatusSubscription?.cancel();
    updateUserStatus(false);
    if (isRecorderInit.value) {
      soundRecorder.closeRecorder();
    }
    _recordingTimer?.cancel();
    super.onClose();
  }
}
