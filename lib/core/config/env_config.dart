import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static final EnvConfig _instance = EnvConfig._internal();
  factory EnvConfig() => _instance;
  EnvConfig._internal();

  bool _isInitialized = false;

  // Firebase Configuration
  String get firebaseApiKey => _getEnvVar('FIREBASE_API_KEY');
  String get firebaseAppId => _getEnvVar('FIREBASE_APP_ID');
  String get firebaseMessagingSenderId =>
      _getEnvVar('FIREBASE_MESSAGING_SENDER_ID');
  String get firebaseProjectId => _getEnvVar('FIREBASE_PROJECT_ID');
  String get firebaseStorageBucket => _getEnvVar('FIREBASE_STORAGE_BUCKET');
  String get firebaseAuthDomain => _getEnvVar('FIREBASE_AUTH_DOMAIN');

  // App Configuration
  String get appName => _getEnvVar('APP_NAME', defaultValue: 'TuncBT');
  String get appVersion => _getEnvVar('APP_VERSION', defaultValue: '2.0.0');
  String get appEnv => _getEnvVar('APP_ENV', defaultValue: 'production');

  // API Configuration
  String get apiBaseUrl => _getEnvVar('API_BASE_URL');
  String get apiVersion => _getEnvVar('API_VERSION', defaultValue: 'v1');

  // Push Notifications
  String get pushNotificationKey => _getEnvVar('PUSH_NOTIFICATION_KEY');
  String get fcmServerKey => _getEnvVar('FCM_SERVER_KEY');
  String get notificationChannelId => _getEnvVar(
        'NOTIFICATION_CHANNEL_ID',
        defaultValue: 'high_importance_channel',
      );
  String get notificationChannelName => _getEnvVar(
        'NOTIFICATION_CHANNEL_NAME',
        defaultValue: 'High Importance Notifications',
      );
  String get notificationChannelDescription => _getEnvVar(
        'NOTIFICATION_CHANNEL_DESCRIPTION',
        defaultValue: 'This channel is used for important notifications.',
      );

  // Analytics
  String get analyticsTrackingId => _getEnvVar('ANALYTICS_TRACKING_ID');

  // Storage Configuration
  String get storageMaxSize =>
      _getEnvVar('STORAGE_MAX_SIZE', defaultValue: '50MB');
  String get maxUploadSize =>
      _getEnvVar('MAX_UPLOAD_SIZE', defaultValue: '10MB');

  // Security
  String get jwtSecret => _getEnvVar('JWT_SECRET');
  String get encryptionKey => _getEnvVar('ENCRYPTION_KEY');

  // Cache Configuration
  int get cacheDuration => _getIntEnvVar('CACHE_DURATION', defaultValue: 3600);
  String get maxCacheSize =>
      _getEnvVar('MAX_CACHE_SIZE', defaultValue: '100MB');

  // Team Configuration
  int get maxTeamSize => _getIntEnvVar('MAX_TEAM_SIZE', defaultValue: 50);
  int get referralCodeLength =>
      _getIntEnvVar('REFERRAL_CODE_LENGTH', defaultValue: 8);

  // Error Tracking
  bool get errorReportingEnabled => _getBoolEnvVar('ERROR_REPORTING_ENABLED');

  // Environment Loading
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final envFileName = '.env.${appEnv.toLowerCase()}';
      await dotenv.load(fileName: envFileName);
      print('Ortam yapılandırması yüklendi: $envFileName');
      _validateRequiredVariables();
      _isInitialized = true;
    } catch (e) {
      print('Ortam yapılandırması yüklenirken hata oluştu: $e');
      try {
        print('Varsayılan production ortamı yükleniyor...');
        await dotenv.load(fileName: '.env.production');
        _validateRequiredVariables();
        _isInitialized = true;
      } catch (e) {
        print('Kritik hata: Hiçbir ortam yapılandırması yüklenemedi!');
        rethrow;
      }
    }
  }

  // Private Helper Methods
  String _getEnvVar(String key, {String defaultValue = ''}) {
    _checkInitialization();
    return dotenv.env[key] ?? defaultValue;
  }

  int _getIntEnvVar(String key, {int defaultValue = 0}) {
    _checkInitialization();
    return int.tryParse(dotenv.env[key] ?? '') ?? defaultValue;
  }

  bool _getBoolEnvVar(String key, {bool defaultValue = false}) {
    _checkInitialization();
    final value = dotenv.env[key]?.toLowerCase();
    if (value == null) return defaultValue;
    return value == 'true' || value == '1' || value == 'yes';
  }

  void _checkInitialization() {
    if (!_isInitialized) {
      throw StateError(
          'EnvConfig henüz başlatılmadı. Önce init() metodunu çağırın.');
    }
  }

  void _validateRequiredVariables() {
    final requiredVars = [
      'FIREBASE_API_KEY',
      'FIREBASE_APP_ID',
      'FIREBASE_PROJECT_ID',
      'API_BASE_URL',
      'JWT_SECRET',
      'ENCRYPTION_KEY',
    ];

    final missingVars =
        requiredVars.where((variable) => _getEnvVar(variable).isEmpty).toList();

    if (missingVars.isNotEmpty) {
      throw Exception(
        'Gerekli ortam değişkenleri eksik: ${missingVars.join(', ')}',
      );
    }
  }

  // Environment Type Checks
  bool get isProduction => appEnv.toLowerCase() == 'production';
  bool get isDevelopment => appEnv.toLowerCase() == 'development';
  bool get isStaging => appEnv.toLowerCase() == 'staging';

  // Debug Information
  Map<String, dynamic> toJson() => {
        'appName': appName,
        'appVersion': appVersion,
        'appEnv': appEnv,
        'apiBaseUrl': apiBaseUrl,
        'apiVersion': apiVersion,
        'firebaseProjectId': firebaseProjectId,
        'notificationChannelId': notificationChannelId,
        'analyticsTrackingId': analyticsTrackingId,
        'storageMaxSize': storageMaxSize,
        'maxUploadSize': maxUploadSize,
        'cacheDuration': cacheDuration,
        'maxCacheSize': maxCacheSize,
        'maxTeamSize': maxTeamSize,
        'referralCodeLength': referralCodeLength,
        'errorReportingEnabled': errorReportingEnabled,
      };

  @override
  String toString() => 'EnvConfig(${toJson()})';
}
