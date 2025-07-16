import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuncbt/core/config/router.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/auth/auth_bindings.dart';
import 'package:tuncbt/view/screens/screens.dart';
import 'package:tuncbt/core/services/push_notifications.dart';
import 'package:tuncbt/core/services/auth_service.dart';
import 'package:tuncbt/core/services/team_service_controller.dart';
import 'package:tuncbt/core/services/navigation_service.dart';
import 'package:tuncbt/core/services/firebase_listener_service.dart';
import 'package:tuncbt/core/services/operation_queue_service.dart';
import 'package:tuncbt/core/services/cache_service.dart';
import 'package:tuncbt/core/services/logout_service.dart';
import 'package:tuncbt/core/services/error_handling_service.dart';
import 'package:tuncbt/user_state.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tuncbt/core/config/env_config.dart';

const String LANGUAGE_CODE = 'languageCode';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig().init();

  // Initialize Firebase
  await Firebase.initializeApp();

  // SharedPreferences'ı başlat
  final prefs = await SharedPreferences.getInstance();

  // Kayıtlı dil kodunu al veya varsayılan olarak 'tr' kullan
  final String savedLanguage = prefs.getString(LANGUAGE_CODE) ?? 'tr';

  // Mevcut kullanıcıları yeni yapıya geçir
  // Rawait UserModel.migrateExistingUsers();

  // timeago dil desteği
  timeago.setLocaleMessages('tr', timeago.TrMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('de', timeago.DeMessages());
  timeago.setDefaultLocale(savedLanguage);

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

  // Initialize TeamServiceController
  Get.put(TeamServiceController());

  runApp(MyApp(prefs: prefs, initialLocale: savedLanguage));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  final String initialLocale;

  const MyApp({
    Key? key,
    required this.prefs,
    required this.initialLocale,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String _currentLocale;

  @override
  void initState() {
    super.initState();
    _currentLocale = widget.initialLocale;
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    final notificationSystems = Get.find<PushNotificationSystems>();

    String? token = await notificationSystems.getFirebaseToken();
    print('FCM Token: $token');

    notificationSystems.subscribeToTopic('notifications');

    // Notification handling is now done internally by PushNotificationSystems
    // and routing through NavigationService
  }

  void _changeLanguage(String languageCode) async {
    setState(() {
      _currentLocale = languageCode;
    });
    await widget.prefs.setString(LANGUAGE_CODE, languageCode);
    timeago.setDefaultLocale(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TuncBT',
        theme: AppTheme.lightTheme,
        initialBinding: AuthBindings(),
        getPages: RouteManager.routes,
        home: const UserState(),
        locale: Locale(_currentLocale),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr'), // Turkish
          Locale('en'), // English
          Locale('de'), // German
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) {
            return supportedLocales.first;
          }

          // Desteklenen dilleri kontrol et
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }

          // Eğer desteklenmeyen bir dil ise varsayılan olarak Türkçe'ye dön
          return const Locale('tr');
        },
      ),
    );
  }
}
