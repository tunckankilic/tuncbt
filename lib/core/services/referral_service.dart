import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import '../config/constants.dart';
import '../config/firebase_constants.dart';

class ReferralService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _random = Random.secure();
  static const int _maxRetries = 3;

  /// Referral kodu formatını kontrol eder
  /// Format: 8 karakter, sadece büyük harf ve rakam
  bool isValidFormat(String code) {
    if (code.length != Constants.referralCodeLength) return false;
    return RegExp(r'^[A-Z0-9]{8}$').hasMatch(code);
  }

  /// Benzersiz bir referral kodu oluşturur
  Future<String> generateUniqueCode() async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        final code = _generateCode();
        final exists = await checkCodeExists(code);

        if (!exists) {
          return code;
        }
        retryCount++;
      } on FirebaseException catch (e) {
        throw ReferralException(
          'Firebase bağlantı hatası: ${e.message}',
          errorType: ReferralErrorType.firebaseError,
        );
      } catch (e) {
        throw ReferralException(
          'Beklenmeyen bir hata oluştu: $e',
          errorType: ReferralErrorType.unknown,
        );
      }
    }
    throw ReferralException(
      'Benzersiz kod oluşturulamadı, lütfen tekrar deneyin',
      errorType: ReferralErrorType.maxRetriesExceeded,
    );
  }

  /// Referral kodunun varlığını kontrol eder
  Future<bool> checkCodeExists(String code) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.teams)
          .where(FirebaseFields.referralCode, isEqualTo: code)
          .get();
      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      throw ReferralException(
        'Referral kodu kontrolü başarısız: ${e.message}',
        errorType: ReferralErrorType.firebaseError,
      );
    } catch (e) {
      throw ReferralException(
        'Referral kodu kontrolünde hata: $e',
        errorType: ReferralErrorType.unknown,
      );
    }
  }

  /// 8 karakterli benzersiz bir kod oluşturur
  String _generateCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomBytes = List<int>.generate(16, (i) => _random.nextInt(256));
    final input = '$timestamp${base64Url.encode(randomBytes)}';
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    final code = hash
        .toString()
        .substring(0, Constants.referralCodeLength)
        .toUpperCase();

    // Sadece harf ve rakamlardan oluşan bir kod oluştur
    return code.replaceAll(RegExp(r'[^A-Z0-9]'), 'A');
  }

  /// Referral kodunu doğrular ve detaylı hata mesajları döner
  Future<ReferralValidationResult> validateCode(String code) async {
    try {
      if (!isValidFormat(code)) {
        return ReferralValidationResult(
          isValid: false,
          error: ReferralException(
            Constants.invalidReferralCode,
            errorType: ReferralErrorType.invalidFormat,
          ),
        );
      }

      final exists = await checkCodeExists(code);
      if (!exists) {
        return ReferralValidationResult(
          isValid: false,
          error: ReferralException(
            Constants.teamNotFound,
            errorType: ReferralErrorType.codeNotFound,
          ),
        );
      }

      return ReferralValidationResult(isValid: true);
    } catch (e) {
      return ReferralValidationResult(
        isValid: false,
        error: e is ReferralException
            ? e
            : ReferralException(
                'Kod doğrulama sırasında hata oluştu: $e',
                errorType: ReferralErrorType.unknown,
              ),
      );
    }
  }

  Future<bool> validateReferralCode(String code) async {
    try {
      final referralDoc =
          await _firestore.collection('referral_codes').doc(code).get();

      return referralDoc.exists && !referralDoc.data()?['isUsed'];
    } catch (e) {
      print('Referral code validation error: $e');
      return false;
    }
  }
}

/// Referral kodu doğrulama sonucu
class ReferralValidationResult {
  final bool isValid;
  final ReferralException? error;

  ReferralValidationResult({
    required this.isValid,
    this.error,
  });
}

/// Referral işlemleri için özel hata sınıfı
class ReferralException implements Exception {
  final String message;
  final ReferralErrorType errorType;

  ReferralException(this.message, {required this.errorType});

  @override
  String toString() => message;
}

/// Referral hata tipleri
enum ReferralErrorType {
  invalidFormat,
  codeNotFound,
  maxRetriesExceeded,
  firebaseError,
  unknown,
}
