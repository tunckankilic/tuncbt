import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tuncbt/core/config/env_config.dart';
import 'package:tuncbt/core/config/router.dart';
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

  // Load environment variables
  await dotenv.load(fileName: ".env.production");

  // Initialize EnvConfig
  await EnvConfig().init();

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

  // Initialize core services
  Get.put(AuthService());
  Get.put(TeamServiceController());
  Get.put(FirebaseListenerService());
  Get.put(NavigationService());
  Get.put(LogoutService());

  // Initialize core services with lazy loading
  Get.lazyPut(() => AuthService(), fenix: true);
  Get.lazyPut(() => TeamController(), fenix: true);
  Get.lazyPut(() => TeamServiceController(), fenix: true);
  Get.lazyPut(() => LogoutService(), fenix: true);
  Get.lazyPut(() => ErrorHandlingService(), fenix: true);

  // Initialize Firebase related services
  Get.put(FirebaseListenerService());
  Get.put(OperationQueueService());

  final pushNotificationSystems = PushNotificationSystems();
  await pushNotificationSystems.init();
  Get.put(pushNotificationSystems);

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

  // Responsive design için dinamik boyut hesaplama
  Size _getDesignSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    print('Screen Size: ${screenWidth}x${screenHeight}');

    // 13 inch tablet için çok büyük design size
    if (screenWidth >= 1200) {
      // Büyük tablet (13 inch+) için maksimum boyut
      return Size(screenWidth * 0.9, screenHeight * 0.9);
    } else if (screenWidth >= 800) {
      // Orta tablet için
      return Size(screenWidth * 0.85, screenHeight * 0.85);
    } else if (screenWidth >= 600) {
      // Küçük tablet için
      return Size(screenWidth * 0.8, screenHeight * 0.8);
    } else {
      // Telefon için standart boyut
      return const Size(360, 690);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: _getDesignSize(context),
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'TuncBT',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            useMaterial3: true,
          ),
          builder: (context, child) {
            // 13 inch tablet için ek responsive ayar
            final screenWidth = MediaQuery.of(context).size.width;
            if (screenWidth >= 1200) {
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: child,
              );
            }
            return child!;
          },
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
          initialRoute: '/',
          getPages: RouteManager.routes,
          home: const UserState(),
          unknownRoute: GetPage(
            name: '/not-found',
            page: () => const UserState(),
          ),
        );
      },
    );
  }
}
