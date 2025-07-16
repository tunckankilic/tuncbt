import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tuncbt/core/services/logout_service.dart';

enum ErrorSeverity {
  low, // Kullanıcıya gösterilmesi gerekmeyen hatalar
  medium, // Snackbar ile gösterilecek hatalar
  high, // Dialog ile gösterilecek hatalar
  critical, // Uygulama çökmesi/oturum sonlandırma gerektiren hatalar
}

class AppError {
  final String code;
  final String message;
  final ErrorSeverity severity;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final String? context;

  AppError({
    required this.code,
    required this.message,
    required this.severity,
    this.originalError,
    this.stackTrace,
    this.context,
  });

  @override
  String toString() {
    return 'AppError{code: $code, message: $message, severity: $severity, context: $context}';
  }
}

class ErrorHandlingService extends GetxService {
  // Error state
  final RxBool hasError = false.obs;
  final Rx<AppError?> currentError = Rx<AppError?>(null);
  final RxInt errorCount = 0.obs;

  // Services
  late final LogoutService _logoutService;

  @override
  void onInit() {
    super.onInit();
    _logoutService = Get.find<LogoutService>();
  }

  // Handle Firebase Auth Errors
  AppError handleFirebaseAuthError(FirebaseAuthException error) {
    String message;
    ErrorSeverity severity;

    switch (error.code) {
      case 'user-not-found':
        message = 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı';
        severity = ErrorSeverity.medium;
        break;
      case 'wrong-password':
        message = 'Geçersiz şifre';
        severity = ErrorSeverity.medium;
        break;
      case 'invalid-email':
        message = 'Geçersiz e-posta adresi';
        severity = ErrorSeverity.medium;
        break;
      case 'user-disabled':
        message = 'Bu hesap devre dışı bırakılmış';
        severity = ErrorSeverity.high;
        break;
      case 'email-already-in-use':
        message = 'Bu e-posta adresi zaten kullanımda';
        severity = ErrorSeverity.medium;
        break;
      case 'operation-not-allowed':
        message = 'Bu işlem şu anda kullanılamıyor';
        severity = ErrorSeverity.high;
        break;
      case 'weak-password':
        message = 'Şifre çok zayıf';
        severity = ErrorSeverity.medium;
        break;
      case 'requires-recent-login':
        message = 'Bu işlem için yeniden giriş yapmanız gerekiyor';
        severity = ErrorSeverity.high;
        break;
      default:
        message = 'Bir hata oluştu: ${error.message}';
        severity = ErrorSeverity.medium;
    }

    return AppError(
      code: error.code,
      message: message,
      severity: severity,
      originalError: error,
      stackTrace: error.stackTrace,
      context: 'Firebase Authentication',
    );
  }

  // Handle Firebase Firestore Errors
  AppError handleFirestoreError(dynamic error) {
    String code;
    String message;
    ErrorSeverity severity;

    if (error is FirebaseException) {
      code = error.code;
      switch (error.code) {
        case 'permission-denied':
          message = 'Bu işlem için yetkiniz yok';
          severity = ErrorSeverity.high;
          break;
        case 'unavailable':
          message = 'Sunucuya ulaşılamıyor';
          severity = ErrorSeverity.high;
          break;
        case 'not-found':
          message = 'İstenen veri bulunamadı';
          severity = ErrorSeverity.medium;
          break;
        case 'already-exists':
          message = 'Bu veri zaten mevcut';
          severity = ErrorSeverity.medium;
          break;
        default:
          message = 'Veritabanı hatası: ${error.message}';
          severity = ErrorSeverity.medium;
      }
    } else {
      code = 'unknown';
      message = 'Beklenmeyen bir hata oluştu';
      severity = ErrorSeverity.high;
    }

    return AppError(
      code: code,
      message: message,
      severity: severity,
      originalError: error,
      stackTrace: error is Error ? error.stackTrace : null,
      context: 'Firebase Firestore',
    );
  }

  // Handle Network Errors
  AppError handleNetworkError(dynamic error) {
    return AppError(
      code: 'network_error',
      message: 'İnternet bağlantısı hatası',
      severity: ErrorSeverity.high,
      originalError: error,
      context: 'Network',
    );
  }

  // Handle Team Operation Errors
  AppError handleTeamOperationError(dynamic error, String operation) {
    String message;
    ErrorSeverity severity;

    switch (operation) {
      case 'join':
        message = 'Takıma katılma işlemi başarısız oldu';
        severity = ErrorSeverity.high;
        break;
      case 'leave':
        message = 'Takımdan ayrılma işlemi başarısız oldu';
        severity = ErrorSeverity.high;
        break;
      case 'update':
        message = 'Takım bilgileri güncellenemedi';
        severity = ErrorSeverity.medium;
        break;
      case 'delete':
        message = 'Takım silinemedi';
        severity = ErrorSeverity.high;
        break;
      default:
        message = 'Takım işlemi başarısız oldu';
        severity = ErrorSeverity.medium;
    }

    return AppError(
      code: 'team_operation_error',
      message: message,
      severity: severity,
      originalError: error,
      context: 'Team Operations',
    );
  }

  // Handle Critical Errors
  Future<void> handleCriticalError(AppError error) async {
    print('Critical Error: $error');

    // Log error
    _logError(error);

    // Show error dialog
    await Get.dialog(
      AlertDialog(
        title: Text('Kritik Hata'),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              await _logoutService.forceLogout(
                reason: 'Kritik bir hata nedeniyle oturumunuz sonlandırıldı',
              );
            },
            child: Text('Tamam'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Show error to user based on severity
  void showError(AppError error) {
    hasError.value = true;
    currentError.value = error;
    errorCount.value++;

    // Log error
    _logError(error);

    switch (error.severity) {
      case ErrorSeverity.low:
        // Just log, don't show to user
        break;

      case ErrorSeverity.medium:
        Get.snackbar(
          'Hata',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        break;

      case ErrorSeverity.high:
        Get.dialog(
          AlertDialog(
            title: Text('Hata'),
            content: Text(error.message),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Tamam'),
              ),
            ],
          ),
        );
        break;

      case ErrorSeverity.critical:
        handleCriticalError(error);
        break;
    }
  }

  // Clear current error
  void clearError() {
    hasError.value = false;
    currentError.value = null;
  }

  // Log error
  void _logError(AppError error) {
    print('\n=== ERROR LOG ===');
    print('Code: ${error.code}');
    print('Message: ${error.message}');
    print('Severity: ${error.severity}');
    print('Context: ${error.context}');
    print('Original Error: ${error.originalError}');
    if (error.stackTrace != null) {
      print('Stack Trace:\n${error.stackTrace}');
    }
    print('================\n');
  }

  // Get error statistics
  Map<String, dynamic> getErrorStats() {
    return {
      'totalErrors': errorCount.value,
      'hasCurrentError': hasError.value,
      'currentError': currentError.value?.toString(),
    };
  }

  // Reset error statistics
  void resetErrorStats() {
    errorCount.value = 0;
    clearError();
  }
}
