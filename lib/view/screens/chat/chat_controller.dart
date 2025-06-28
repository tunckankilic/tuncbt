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

  // Stream subscription for user status
  StreamSubscription? _userStatusSubscription;

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late FlutterSoundRecorder soundRecorder;

  @override
  void onInit() {
    super.onInit();
    soundRecorder = FlutterSoundRecorder();
    updateUserStatus(true);
  }

  Future<bool> showPermissionRationale() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Mikrofon İzni'),
        content: const Text(
            'Sesli mesaj göndermek için mikrofon iznine ihtiyacımız var. '
            'İzin vermek ister misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('ŞIMDI DEĞIL'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('DEVAM ET'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  void _showOpenSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('İzin Gerekli'),
        content: const Text('Sesli mesaj göndermek için mikrofon izni gerekli. '
            'Lütfen ayarlardan izin verin.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İPTAL'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('AYARLARI AÇ'),
          ),
        ],
      ),
    );
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
    } catch (e) {
      print('Recording error: $e');
      Get.snackbar(
        'Hata',
        'Kayıt başlatılamadı',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }

  // Ses kaydını durdur
  Future<String?> stopRecording() async {
    if (!isRecording.value) return null;

    try {
      final filePath = await soundRecorder.stopRecorder();
      isRecording.value = false;
      return filePath;
    } catch (e) {
      print('Stop recording error: $e');
      Get.snackbar(
        'Hata',
        'Kayıt durdurulamadı',
        backgroundColor: Colors.red.withOpacity(0.1),
      );
      return null;
    }
  }

  Future<void> _initAudio() async {
    try {
      // Önce izin durumunu kontrol et
      final status = await Permission.microphone.status;

      if (status.isDenied) {
        // İzin henüz istenmemiş, kullanıcıya açıklama göster
        final showRationale = await showPermissionRationale();
        if (!showRationale) return;
      }

      // İzni iste
      final result = await Permission.microphone.request();

      if (result.isGranted) {
        // İzin verildi, kaydediciyi başlat
        await soundRecorder.openRecorder();
        isRecorderInit.value = true;
      } else if (result.isPermanentlyDenied) {
        // Kullanıcı kalıcı olarak reddetti, ayarlara yönlendir
        _showOpenSettingsDialog();
      } else {
        // İzin reddedildi, kullanıcıya bilgi ver
        Get.snackbar(
          'Permission Required',
          'Microphone permission is required for voice messages',
          backgroundColor: Colors.red.withOpacity(0.1),
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print('Audio initialization error: $e');
      Get.snackbar(
        'Error',
        'Failed to initialize audio recorder',
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
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
      await _firestore.collection('users').doc(receiver.value?.id).update({
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
        return Message.fromJson(data);
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
      return snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
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
        throw Exception('User not authenticated');
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
        // MessageReply ile ilgili alanları nullable yap ve null kontrolü ekle
        replyTo: null, // messageReply.value?.message yerine direkt null
        repliedTo: null, // Yanıtlama özelliğini şimdilik devre dışı bırak
        repliedMessageType: null, // Reply type'ı da null bırak
        mediaUrl: null,
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

      // 7. Input temizleme
      messageController.clear();

      print('Message sent successfully');
    } catch (e, stackTrace) {
      print('Error sending message:');
      print('Error: $e');
      print('Stack trace: $stackTrace');

      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
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
        'Error',
        'Failed to send file: $e',
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
        'Success',
        'GIF sent successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error sending GIF: $e'); // Hata ayıklama için
      Get.snackbar(
        'Error',
        'Failed to send GIF: $e',
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
    messageReply.value = MessageReply(
      message,
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
    isShowSendButton.value = value.isNotEmpty;
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
    _userStatusSubscription?.cancel();
    updateUserStatus(false);
    if (isRecorderInit.value) {
      soundRecorder.closeRecorder();
    }

    super.onClose();
  }
}
