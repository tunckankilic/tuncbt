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
  Future<String> generateUniqueCode({
    required String teamId,
    required String userId,
    Duration validity = const Duration(days: 7),
  }) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        final code = _generateSecureCode();
        final exists = await checkCodeExists(code);

        if (!exists) {
          // Yeni referral kodu oluştur
          await _firestore.collection('referral_codes').doc(code).set({
            'code': code,
            'teamId': teamId,
            'createdBy': userId,
            'createdAt': FieldValue.serverTimestamp(),
            'expiryDate': Timestamp.fromDate(
              DateTime.now().add(validity),
            ),
            'isUsed': false,
            'usedBy': null,
            'usedAt': null,
            'useCount': 0,
            'maxUses': 1, // Varsayılan olarak bir kez kullanılabilir
          });
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
      final doc = await _firestore.collection('referral_codes').doc(code).get();
      return doc.exists;
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

  /// Güvenli bir şekilde 8 karakterli benzersiz bir kod oluşturur
  String _generateSecureCode() {
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
      // Format kontrolü
      if (!isValidFormat(code)) {
        return ReferralValidationResult(
          isValid: false,
          error: ReferralException(
            Constants.invalidReferralCode,
            errorType: ReferralErrorType.invalidFormat,
          ),
        );
      }

      // Kod varlığı kontrolü
      final referralDoc =
          await _firestore.collection('referral_codes').doc(code).get();
      if (!referralDoc.exists) {
        return ReferralValidationResult(
          isValid: false,
          error: ReferralException(
            Constants.teamNotFound,
            errorType: ReferralErrorType.codeNotFound,
          ),
        );
      }

      final data = referralDoc.data()!;

      // Kullanım durumu kontrolü
      if (data['isUsed'] == true ||
          (data['useCount'] ?? 0) >= (data['maxUses'] ?? 1)) {
        return ReferralValidationResult(
          isValid: false,
          error: ReferralException(
            'Bu kod daha önce kullanılmış',
            errorType: ReferralErrorType.codeUsed,
          ),
        );
      }

      // Geçerlilik süresi kontrolü
      final expiryDate = (data['expiryDate'] as Timestamp?)?.toDate();
      if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
        return ReferralValidationResult(
          isValid: false,
          error: ReferralException(
            'Bu kodun geçerlilik süresi dolmuş',
            errorType: ReferralErrorType.codeExpired,
          ),
        );
      }

      // Takım kontrolü
      final teamId = data['teamId'];
      if (teamId == null) {
        return ReferralValidationResult(
          isValid: false,
          error: ReferralException(
            'Geçersiz takım referansı',
            errorType: ReferralErrorType.invalidTeam,
          ),
        );
      }

      final teamDoc = await _firestore.collection('teams').doc(teamId).get();
      if (!teamDoc.exists || !(teamDoc.data()?['isActive'] ?? false)) {
        return ReferralValidationResult(
          isValid: false,
          error: ReferralException(
            'Takım bulunamadı veya aktif değil',
            errorType: ReferralErrorType.invalidTeam,
          ),
        );
      }

      return ReferralValidationResult(
        isValid: true,
        teamId: teamId,
        createdBy: data['createdBy'],
      );
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

  /// Referral kodunu kullan ve gerekli güncellemeleri yap
  Future<void> useCode(String code, String userId) async {
    try {
      final docRef = _firestore.collection('referral_codes').doc(code);
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) {
          throw ReferralException(
            'Referral kodu bulunamadı',
            errorType: ReferralErrorType.codeNotFound,
          );
        }

        final data = doc.data()!;
        final currentUseCount = data['useCount'] ?? 0;
        final maxUses = data['maxUses'] ?? 1;

        if (currentUseCount >= maxUses) {
          throw ReferralException(
            'Bu kod maksimum kullanım sayısına ulaşmış',
            errorType: ReferralErrorType.codeUsed,
          );
        }

        transaction.update(docRef, {
          'useCount': currentUseCount + 1,
          'isUsed': currentUseCount + 1 >= maxUses,
          'usedBy': FieldValue.arrayUnion([userId]),
          'lastUsedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw ReferralException(
        'Kod kullanımı sırasında hata: $e',
        errorType: ReferralErrorType.unknown,
      );
    }
  }
}

/// Referral kodu doğrulama sonucu
class ReferralValidationResult {
  final bool isValid;
  final ReferralException? error;
  final String? teamId;
  final String? createdBy;

  ReferralValidationResult({
    required this.isValid,
    this.error,
    this.teamId,
    this.createdBy,
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
  codeUsed,
  codeExpired,
  maxRetriesExceeded,
  firebaseError,
  invalidTeam,
  unknown,
}
