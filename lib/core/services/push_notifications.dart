import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PushNotificationSystems extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> init() async {
    await _initializeLocalNotifications();
    await _requestNotificationPermissions();
    await _configureForegroundNotificationPresentationOptions();
    await _setupInteractedMessage();
    _registerForegroundMessageHandler();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
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
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _registerForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.messageId}");
      _showLocalNotification(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    print("Handling a message: ${message.messageId}");
    // TODO: Implement your logic for handling the message when the app is opened from a notification
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: android.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> createTaskAddedNotification(
      String taskId, String uploadedBy) async {
    await _firestore.collection('notifications').add({
      'message': 'Yeni görev eklendi',
      'taskId': taskId,
      'uploadedBy': uploadedBy,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
      'type': 'new_task',
    });
  }

  Future<void> createStatusUpdateNotification(
      String taskId, bool newStatus, String uploadedBy) async {
    await _firestore.collection('notifications').add({
      'message':
          'Task status updated to ${newStatus ? "completed" : "incomplete"}',
      'taskId': taskId,
      'uploadedBy': uploadedBy,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
      'type': 'status_update',
    });
  }

  Future<void> createCommentNotification(String taskId, String commentId,
      String commenterName, String uploadedBy) async {
    await _firestore.collection('notifications').add({
      'message': '$commenterName commented on a task',
      'taskId': taskId,
      'commentId': commentId,
      'uploadedBy': uploadedBy,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
      'type': 'new_comment',
    });
  }

  Future<String?> getFirebaseToken() async {
    return await _firebaseMessaging.getToken();
  }

  void subscribeToTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  void unsubscribeFromTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  void setNotificationHandler(Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessage.listen(handler);
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }
}
