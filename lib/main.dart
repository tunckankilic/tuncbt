import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tuncbt/core/config/env_config.dart';
import 'package:tuncbt/core/services/auth_service.dart';
import 'package:tuncbt/core/services/cache_service.dart';
import 'package:tuncbt/core/services/error_handling_service.dart';
import 'package:tuncbt/core/services/firebase_listener_service.dart';
import 'package:tuncbt/core/services/logout_service.dart';
import 'package:tuncbt/core/services/navigation_service.dart';
import 'package:tuncbt/core/services/operation_queue_service.dart';
import 'package:tuncbt/core/services/push_notifications.dart';
import 'package:tuncbt/core/services/team_controller.dart';
import 'package:tuncbt/core/services/team_service_controller.dart';
import 'package:tuncbt/firebase_options.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/user_state.dart';

const String LANGUAGE_CODE = 'languageCode';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // SharedPreferences'i başlat
  final prefs = await SharedPreferences.getInstance();

  // Kayıtlı dil kodunu al veya varsayılan olarak 'tr' kullan
  String savedLanguage;
  try {
    savedLanguage = prefs.getString(LANGUAGE_CODE) ?? 'tr';
    if (!['tr', 'en', 'de'].contains(savedLanguage)) {
      savedLanguage = 'tr';
      await prefs.setString(LANGUAGE_CODE, 'tr');
    }
  } catch (e) {
    print('Error loading language: $e');
    savedLanguage = 'tr';
    await prefs.setString(LANGUAGE_CODE, 'tr');
  }

  // timeago dil desteği
  try {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    timeago.setLocaleMessages('en', timeago.EnMessages());
    timeago.setLocaleMessages('de', timeago.DeMessages());
    timeago.setDefaultLocale(savedLanguage);
  } catch (e) {
    print('Error setting timeago locale: $e');
  }

  // Initialize services in Get
  Get.put(prefs); // Register SharedPreferences

  // Initialize CacheService first
  Get.put(CacheService(prefs));

  // Initialize NavigationService
  Get.put(NavigationService());

  // Initialize FirebaseListenerService
  Get.put(FirebaseListenerService());

  // Initialize OperationQueueService
  Get.put(OperationQueueService());

  // Initialize LogoutService
  Get.put(LogoutService());

  // Initialize ErrorHandlingService
  Get.put(ErrorHandlingService());

  final pushNotificationSystems = PushNotificationSystems();
  await pushNotificationSystems.init();
  Get.put(pushNotificationSystems);

  // Initialize AuthService
  Get.put(AuthService());

  // Initialize TeamController
  Get.put(TeamController());

  // Initialize TeamServiceController
  Get.put(TeamServiceController());

  runApp(MyApp(
    initialLocale: savedLanguage,
  ));
}

class MyApp extends StatefulWidget {
  final String initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  static final GlobalKey<MyAppState> key = GlobalKey<MyAppState>();
  Locale _locale = const Locale('tr');

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.initialLocale);
  }

  void changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TuncBT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
      ],
      home: const UserState(),
    );
  }
}
