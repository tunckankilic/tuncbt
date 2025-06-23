import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/l10n/app_localizations.dart';

/// Temel takım hatası
class TeamException implements Exception {
  final String message;
  final String? code;
  final String? recovery;

  TeamException(this.message, {this.code, this.recovery});

  @override
  String toString() => message;
}

/// Ağ bağlantısı hataları
class TeamNetworkException extends TeamException {
  TeamNetworkException()
      : super('Network connection error',
            code: 'network_error',
            recovery: 'Check your internet connection and try again');
}

/// İzin hataları
class TeamPermissionException extends TeamException {
  TeamPermissionException()
      : super('Permission denied',
            code: 'permission_denied',
            recovery: 'You do not have permission to perform this action');
}

/// Takım kapasitesi hataları
class TeamCapacityException extends TeamException {
  TeamCapacityException()
      : super('Team capacity exceeded',
            code: 'capacity_exceeded',
            recovery: 'The team has reached its maximum capacity');
}

/// Doğrulama hataları
class TeamValidationException extends TeamException {
  TeamValidationException(String message)
      : super(message,
            code: 'validation_error',
            recovery: 'Please check your input and try again');
}

/// Firebase hataları
class TeamFirebaseException extends TeamException {
  TeamFirebaseException(FirebaseException error)
      : super(error.message ?? 'Firebase error occurred',
            code: error.code, recovery: _getRecoveryMessage(error.code));

  static String _getRecoveryMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action';
      case 'resource-exhausted':
        return 'The operation quota has been exceeded. Please try again later';
      case 'not-found':
        return 'The requested resource was not found';
      default:
        return 'An error occurred. Please try again';
    }
  }
}

/// Hata işleme yardımcı fonksiyonları
class TeamErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    final errorMessage = _getErrorMessage(context, error);
    final recoveryMessage = _getRecoveryMessage(context, error);

    Get.snackbar(
      AppLocalizations.of(context)!.error,
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      mainButton: recoveryMessage != null
          ? TextButton(
              onPressed: () => Get.back(),
              child: Text(
                recoveryMessage,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  static String _getErrorMessage(BuildContext context, dynamic error) {
    if (error is TeamException) {
      return error.message;
    } else if (error is FirebaseException) {
      return TeamFirebaseException(error).message;
    } else {
      return error.toString();
    }
  }

  static String? _getRecoveryMessage(BuildContext context, dynamic error) {
    if (error is TeamException) {
      return error.recovery;
    } else if (error is FirebaseException) {
      return TeamFirebaseException(error).recovery;
    }
    return null;
  }

  static Future<T> retryOperation<T>({
    required Future<T> Function() operation,
    required BuildContext context,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts == maxAttempts) {
          handleError(context, e);
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
    throw TeamException('Maximum retry attempts exceeded');
  }

  static Widget wrapWithErrorHandler({
    required Widget child,
    required Future<void> Function() onRetry,
  }) {
    return ErrorWidget(
      child: child,
      onRetry: onRetry,
    );
  }
}

/// Hata widget'ı
class ErrorWidget extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRetry;

  const ErrorWidget({
    Key? key,
    required this.child,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.error,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}
