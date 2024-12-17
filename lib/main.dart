import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/core/config/router.dart';
import 'package:tuncbt/firebase_options.dart';
import 'package:tuncbt/view/screens/auth/auth_bindings.dart';
import 'package:tuncbt/view/screens/screens.dart';
import 'package:tuncbt/core/services/push_notifications.dart';
import 'package:tuncbt/user_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final pushNotificationSystems = PushNotificationSystems();
  await pushNotificationSystems.init();
  Get.put(pushNotificationSystems);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    final notificationSystems = Get.find<PushNotificationSystems>();
    String? token = await notificationSystems.getFirebaseToken();
    print('FCM Token: $token');

    notificationSystems.subscribeToTopic('notifications');

    notificationSystems.setNotificationHandler((message) {
      print("Received notification: ${message.notification?.title}");

      // Bildirimden task ID'sini ve uploadedBy bilgisini al
      final taskId = message.data['taskId'];
      final uploadedBy = message.data['uploadedBy'];

      if (taskId != null && uploadedBy != null) {
        // Task detay sayfasını aç
        Get.toNamed(TaskDetailsScreen.routeName, arguments: {
          'taskID': taskId,
          'uploadedBy': uploadedBy,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(320, 568),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TuncBT',
        theme: AppTheme.lightTheme,
        initialBinding: AuthBindings(),
        getPages: RouteManager.routes,
        home: const UserState(),
      ),
    );
  }
}
