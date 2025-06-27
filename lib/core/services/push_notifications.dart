import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PushNotificationSystems extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Bildirim kanalı ID'si
  static const String _notificationChannelId = 'high_importance_channel';
  static const String _notificationChannelName =
      'High Importance Notifications';
  static const String _notificationChannelDesc =
      'This channel is used for important notifications.';

  Future<void> init() async {
    try {
      await _initializeLocalNotifications();
      await _requestNotificationPermissions();
      await _configureForegroundNotificationPresentationOptions();
      await _setupInteractedMessage();
      _registerForegroundMessageHandler();
      print('Bildirim sistemi başarıyla başlatıldı');
    } catch (e) {
      print('Bildirim sistemi başlatılırken hata: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Bildirime tıklandı: ${response.payload}');
        _handleNotificationTap(response.payload);
      },
    );

    // Android için bildirim kanalı oluştur
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: _notificationChannelDesc,
      importance: Importance.max,
      enableVibration: true,
      enableLights: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: true,
        announcement: true,
        carPlay: true,
      );

      print('Bildirim izin durumu: ${settings.authorizationStatus}');

      // iOS için ek izinler
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      print('Bildirim izinleri alınırken hata: $e');
    }
  }

  Future<void> _configureForegroundNotificationPresentationOptions() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _setupInteractedMessage() async {
    // Uygulama kapalıyken gelen bildirimler
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Uygulama arka planda iken tıklanan bildirimler
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _registerForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Ön planda bildirim alındı: ${message.messageId}');
      _showLocalNotification(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    print('Bildirim işleniyor: ${message.messageId}');

    final data = message.data;
    final String? type = data['type'];
    final String? taskId = data['taskId'];

    if (type == null || taskId == null) {
      print('Geçersiz bildirim verisi');
      return;
    }

    switch (type) {
      case 'new_task':
        Get.toNamed('/tasks/details', arguments: {
          'taskId': taskId,
          'uploadedBy': data['uploadedBy'],
        });
        break;
      case 'status_update':
        Get.toNamed('/tasks/details', arguments: {
          'taskId': taskId,
          'uploadedBy': data['uploadedBy'],
        });
        break;
      case 'new_comment':
        Get.toNamed('/tasks/details', arguments: {
          'taskId': taskId,
          'uploadedBy': data['uploadedBy'],
          'scrollToComment': data['commentId'],
        });
        break;
      default:
        print('Bilinmeyen bildirim tipi: $type');
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      try {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          Map.from(payload as Map),
        );
        // Bildirime özgü yönlendirme işlemleri
        if (data.containsKey('route')) {
          Get.toNamed(data['route'], arguments: data['arguments']);
        }
      } catch (e) {
        print('Bildirim tıklama işlenirken hata: $e');
      }
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        await _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title ?? 'Yeni Bildirim',
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _notificationChannelId,
              _notificationChannelName,
              channelDescription: _notificationChannelDesc,
              importance: Importance.max,
              priority: Priority.high,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              styleInformation: BigTextStyleInformation(
                notification.body ?? '',
                htmlFormatBigText: true,
                contentTitle: notification.title,
                htmlFormatContentTitle: true,
              ),
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    } catch (e) {
      print('Yerel bildirim gösterilirken hata: $e');
    }
  }

  Future<void> createTaskAddedNotification(
      String taskId, String uploadedBy) async {
    try {
      await _firestore.collection('notifications').add({
        'message': 'Yeni görev eklendi',
        'taskId': taskId,
        'uploadedBy': uploadedBy,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'type': 'new_task',
      });
    } catch (e) {
      print('Görev bildirim oluşturulurken hata: $e');
    }
  }

  Future<void> createStatusUpdateNotification(
      String taskId, bool newStatus, String uploadedBy) async {
    try {
      await _firestore.collection('notifications').add({
        'message':
            'Görev durumu ${newStatus ? "tamamlandı" : "devam ediyor"} olarak güncellendi',
        'taskId': taskId,
        'uploadedBy': uploadedBy,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'type': 'status_update',
      });
    } catch (e) {
      print('Durum güncelleme bildirimi oluşturulurken hata: $e');
    }
  }

  Future<void> createCommentNotification(String taskId, String commentId,
      String commenterName, String uploadedBy) async {
    try {
      await _firestore.collection('notifications').add({
        'message': '$commenterName göreve yorum yaptı',
        'taskId': taskId,
        'commentId': commentId,
        'uploadedBy': uploadedBy,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'type': 'new_comment',
      });
    } catch (e) {
      print('Yorum bildirimi oluşturulurken hata: $e');
    }
  }

  Future<String?> getFirebaseToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Firebase token alınırken hata: $e');
      return null;
    }
  }

  void subscribeToTopic(String topic) {
    try {
      _firebaseMessaging.subscribeToTopic(topic);
      print('$topic konusuna abone olundu');
    } catch (e) {
      print('Konuya abone olunurken hata: $e');
    }
  }

  void unsubscribeFromTopic(String topic) {
    try {
      _firebaseMessaging.unsubscribeFromTopic(topic);
      print('$topic konusundan çıkıldı');
    } catch (e) {
      print('Konudan çıkılırken hata: $e');
    }
  }

  void setNotificationHandler(Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessage.listen(handler);
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }
}
