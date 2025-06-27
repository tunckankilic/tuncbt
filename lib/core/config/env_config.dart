import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Firebase Configuration
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseAuthDomain =>
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'TuncBT';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '2.0.0';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'production';

  // API Configuration
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';

  // Push Notifications
  static String get pushNotificationKey =>
      dotenv.env['PUSH_NOTIFICATION_KEY'] ?? '';
  static String get fcmServerKey => dotenv.env['FCM_SERVER_KEY'] ?? '';
  static String get notificationChannelId =>
      dotenv.env['NOTIFICATION_CHANNEL_ID'] ?? 'high_importance_channel';
  static String get notificationChannelName =>
      dotenv.env['NOTIFICATION_CHANNEL_NAME'] ??
      'High Importance Notifications';
  static String get notificationChannelDescription =>
      dotenv.env['NOTIFICATION_CHANNEL_DESCRIPTION'] ??
      'This channel is used for important notifications.';

  // Analytics
  static String get analyticsTrackingId =>
      dotenv.env['ANALYTICS_TRACKING_ID'] ?? '';

  // Storage Configuration
  static String get storageMaxSize => dotenv.env['STORAGE_MAX_SIZE'] ?? '50MB';
  static String get maxUploadSize => dotenv.env['MAX_UPLOAD_SIZE'] ?? '10MB';

  // Security
  static String get jwtSecret => dotenv.env['JWT_SECRET'] ?? '';
  static String get encryptionKey => dotenv.env['ENCRYPTION_KEY'] ?? '';

  // Cache Configuration
  static int get cacheDuration =>
      int.tryParse(dotenv.env['CACHE_DURATION'] ?? '') ?? 3600;
  static String get maxCacheSize => dotenv.env['MAX_CACHE_SIZE'] ?? '100MB';

  // Team Configuration
  static int get maxTeamSize =>
      int.tryParse(dotenv.env['MAX_TEAM_SIZE'] ?? '') ?? 50;
  static int get referralCodeLength =>
      int.tryParse(dotenv.env['REFERRAL_CODE_LENGTH'] ?? '') ?? 8;

  // Error Tracking
  static bool get errorReportingEnabled =>
      dotenv.env['ERROR_REPORTING_ENABLED']?.toLowerCase() == 'true';

  // Environment Loading
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env.${appEnv.toLowerCase()}');
    } catch (e) {
      print('Environment configuration error: $e');
      // Varsayılan production ortamını yüklemeyi dene
      await dotenv.load(fileName: '.env.production');
    }
  }

  // Validation Methods
  static bool isProduction() => appEnv.toLowerCase() == 'production';
  static bool isDevelopment() => appEnv.toLowerCase() == 'development';
  static bool isStaging() => appEnv.toLowerCase() == 'staging';

  // Helper Methods
  static Map<String, dynamic> toJson() => {
        'firebaseApiKey': firebaseApiKey,
        'firebaseAppId': firebaseAppId,
        'firebaseMessagingSenderId': firebaseMessagingSenderId,
        'firebaseProjectId': firebaseProjectId,
        'firebaseStorageBucket': firebaseStorageBucket,
        'firebaseAuthDomain': firebaseAuthDomain,
        'appName': appName,
        'appVersion': appVersion,
        'appEnv': appEnv,
        'apiBaseUrl': apiBaseUrl,
        'apiVersion': apiVersion,
        'notificationChannelId': notificationChannelId,
        'notificationChannelName': notificationChannelName,
        'analyticsTrackingId': analyticsTrackingId,
        'storageMaxSize': storageMaxSize,
        'maxUploadSize': maxUploadSize,
        'cacheDuration': cacheDuration,
        'maxCacheSize': maxCacheSize,
        'maxTeamSize': maxTeamSize,
        'referralCodeLength': referralCodeLength,
        'errorReportingEnabled': errorReportingEnabled,
      };
}
