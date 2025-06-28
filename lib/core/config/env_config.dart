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
      // Direkt .env.production dosyasını yükle
      await dotenv.load(fileName: '.env.production');
      print('Ortam yapılandırması yüklendi: .env.production');

      _isInitialized = true; // ✅ Set this BEFORE validation
      _validateRequiredVariables();
    } catch (e) {
      print('Kritik hata: .env.production dosyası yüklenemedi: $e');
      print('Dosya assets klasöründe mevcut mu kontrol edin');
      rethrow;
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
    // Sadece kritik Firebase değişkenlerini kontrol et
    final requiredVars = [
      'FIREBASE_API_KEY',
      'FIREBASE_APP_ID',
      'FIREBASE_PROJECT_ID',
    ];

    // ✅ FIX: Use dotenv.env directly instead of _getEnvVar to avoid initialization check
    final missingVars = requiredVars.where((variable) {
      final value = dotenv.env[variable];
      return value == null || value.isEmpty;
    }).toList();

    if (missingVars.isNotEmpty) {
      print('Uyarı: Bazı ortam değişkenleri eksik: ${missingVars.join(', ')}');
      // Geçici olarak exception atmıyoruz, sadece warning veriyoruz
      // throw Exception('Gerekli ortam değişkenleri eksik: ${missingVars.join(', ')}');
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
