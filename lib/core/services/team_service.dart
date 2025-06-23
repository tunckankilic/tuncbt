import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/team.dart';
import '../models/team_member.dart';
import '../models/user_model.dart';
import '../enums/team_role.dart';
import '../constants/constants.dart';
import '../constants/firebase_constants.dart';
import 'referral_service.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/utils/team_errors.dart';
import 'package:tuncbt/utils/team_cache.dart';
import 'package:tuncbt/utils/team_security.dart';
import 'package:tuncbt/utils/team_sync.dart';

class TeamService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _connectivity = Connectivity();
  final maxTeamSize = 50;
  final _cache = Get.put(TeamCache());
  final _sync = Get.put(TeamSync());

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  StreamSubscription? _connectivitySubscription;
  bool _hasNetworkConnection = true;

  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      _hasNetworkConnection = result != ConnectivityResult.none;
    });
  }

  Future<void> _checkNetworkConnection() async {
    if (!_hasNetworkConnection) {
      throw TeamNetworkException();
    }
  }

  Future<void> _handleOperation(
      Future<void> Function() operation, BuildContext context) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      await _checkNetworkConnection();
      await operation();

      Get.snackbar(
        'Success',
        'Operation completed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      TeamErrorHandler.handleError(context, e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Yeni bir takım oluşturur
  Future<TeamOperationResult<Team>> createTeam({
    required String name,
    required String userId,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Girdi doğrulama
      final sanitizedName = TeamSecurity.sanitizeTeamInput(name);

      // Kullanıcı kontrolü
      final user = _auth.currentUser;
      if (user == null) {
        throw TeamPermissionException();
      }

      // Takım oluştur
      final teamDoc =
          await _firestore.collection(FirebaseCollections.teams).add({
        FirebaseFields.name: sanitizedName,
        FirebaseFields.createdAt: FieldValue.serverTimestamp(),
        FirebaseFields.createdBy: user.uid,
        FirebaseFields.memberCount: 1,
      });

      // Üye ekle
      await _firestore
          .collection(FirebaseCollections.teamMembers)
          .doc(user.uid)
          .set({
        FirebaseFields.role: TeamRole.admin.toString().split('.').last,
        FirebaseFields.joinedAt: FieldValue.serverTimestamp(),
      });

      // Kullanıcı bilgilerini güncelle
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .update({
        FirebaseFields.teamId: teamDoc.id,
        FirebaseFields.teamRole: TeamRole.admin.toString().split('.').last,
      });

      final team = Team(
        teamId: teamDoc.id,
        teamName: sanitizedName,
        createdBy: user.uid,
        memberCount: 1,
        referralCode: '',
        createdAt: DateTime.now(),
      );

      // Önbelleğe ekle
      _cache.cacheTeam(teamDoc.id, team);

      return TeamOperationResult.success(data: team);
    } on FirebaseException catch (e) {
      return TeamOperationResult.failure(
        error: TeamException(
          FirebaseErrorCodes.getErrorMessage(e.code),
          errorType: TeamErrorType.firebaseError,
        ),
      );
    } catch (e) {
      return TeamOperationResult.failure(
        error: TeamException(
          'Beklenmeyen bir hata oluştu: $e',
          errorType: TeamErrorType.unknown,
        ),
      );
    }
  }

  /// Bir takıma katılma işlemi
  Future<TeamOperationResult<Team>> joinTeam({
    required String userId,
    required String referralCode,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Girdi doğrulama
      final sanitizedCode = TeamSecurity.sanitizeTeamInput(referralCode);

      // Kullanıcı kontrolü
      final user = _auth.currentUser;
      if (user == null) {
        throw TeamPermissionException();
      }

      // Takım kontrolü
      final teamDoc = await _firestore
          .collection(FirebaseCollections.teams)
          .doc(userId)
          .get();
      if (!teamDoc.exists) {
        throw TeamValidationException('Team not found');
      }

      // Kapasite kontrolü
      final memberCount = teamDoc.data()?[FirebaseFields.memberCount] ?? 0;
      if (memberCount >= maxTeamSize) {
        throw TeamCapacityException();
      }

      // Referans kodu kontrolü
      final referralDoc = await _firestore
          .collection(FirebaseCollections.referrals)
          .where(FirebaseFields.code, isEqualTo: sanitizedCode)
          .where(FirebaseFields.teamId, isEqualTo: userId)
          .get();

      if (referralDoc.docs.isEmpty) {
        throw TeamValidationException('Invalid referral code');
      }

      // İşlemi çevrimdışı kuyruğa ekle
      await _sync.queueOperation(userId, 'update', {
        FirebaseFields.memberCount: FieldValue.increment(1),
      });

      // Üye ekle
      await _firestore
          .collection(FirebaseCollections.teamMembers)
          .doc(user.uid)
          .set({
        FirebaseFields.role: TeamRole.member.toString().split('.').last,
        FirebaseFields.joinedAt: FieldValue.serverTimestamp(),
      });

      // Kullanıcı bilgilerini güncelle
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .update({
        FirebaseFields.teamId: userId,
        FirebaseFields.teamRole: TeamRole.member.toString().split('.').last,
      });

      // Önbelleği temizle
      _cache.invalidateCache(userId);

      return TeamOperationResult.success(
        data: Team(
          teamId: userId,
          teamName: teamDoc.data()?[FirebaseFields.name] ?? '',
          createdBy: user.uid,
          memberCount: memberCount + 1,
          referralCode: '',
          createdAt: DateTime.now(),
        ),
      );
    } on FirebaseException catch (e) {
      return TeamOperationResult.failure(
        error: TeamException(
          FirebaseErrorCodes.getErrorMessage(e.code),
          errorType: TeamErrorType.firebaseError,
        ),
      );
    } catch (e) {
      return TeamOperationResult.failure(
        error: TeamException(
          'Beklenmeyen bir hata oluştu: $e',
          errorType: TeamErrorType.unknown,
        ),
      );
    }
  }

  /// Takım bilgilerini getirir
  Future<TeamOperationResult<Team>> getTeamInfo(String teamId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.teams)
          .doc(teamId)
          .get();

      if (!doc.exists) {
        return TeamOperationResult.failure(
          error: TeamException(
            Constants.teamNotFound,
            errorType: TeamErrorType.teamNotFound,
          ),
        );
      }

      return TeamOperationResult.success(
        data: Team.fromJson(doc.data()!),
      );
    } on FirebaseException catch (e) {
      return TeamOperationResult.failure(
        error: TeamException(
          FirebaseErrorCodes.getErrorMessage(e.code),
          errorType: TeamErrorType.firebaseError,
        ),
      );
    } catch (e) {
      return TeamOperationResult.failure(
        error: TeamException(
          'Beklenmeyen bir hata oluştu: $e',
          errorType: TeamErrorType.unknown,
        ),
      );
    }
  }

  /// Takım üyelerini getirir
  Future<TeamOperationResult<List<TeamMember>>> getTeamMembers(
    String teamId,
  ) async {
    try {
      // Güvenlik kontrolü
      await TeamSecurity.validateTeamDataAccess(teamId);

      // Önbellekten kontrol et
      final cachedMembers = await _cache.getTeamMembers(teamId);
      if (cachedMembers != null) {
        return TeamOperationResult.success(data: cachedMembers);
      }

      // Veritabanından yükle
      final query = _firestore
          .collection(FirebaseCollections.teamMembers)
          .where(FirebaseFields.teamId, isEqualTo: teamId)
          .where(FirebaseFields.isActive, isEqualTo: true)
          .orderBy(FirebaseFields.joinedAt)
          .limit(maxTeamSize);

      final membersSnapshot = await query.get();

      final members = await Future.wait(
        membersSnapshot.docs.map((doc) async {
          final userData = await _firestore
              .collection(FirebaseCollections.users)
              .doc(doc.id)
              .get();

          return TeamMember(
            userId: doc.id,
            teamId: teamId,
            role: doc.data()[FirebaseFields.role] ??
                TeamRole.member.toString().split('.').last,
            joinedAt:
                (doc.data()[FirebaseFields.joinedAt] as Timestamp).toDate(),
            invitedBy: userData.data()?[FirebaseFields.invitedBy] ?? '',
          );
        }),
      );

      // Önbelleğe ekle
      _cache.cacheTeamMembers(teamId, members);

      return TeamOperationResult.success(data: members);
    } on FirebaseException catch (e) {
      return TeamOperationResult.failure(
        error: TeamException(
          FirebaseErrorCodes.getErrorMessage(e.code),
          errorType: TeamErrorType.firebaseError,
        ),
      );
    } catch (e) {
      return TeamOperationResult.failure(
        error: TeamException(
          'Beklenmeyen bir hata oluştu: $e',
          errorType: TeamErrorType.unknown,
        ),
      );
    }
  }

  Future<void> updateTeamSettings(String teamId, Map<String, dynamic> settings,
      BuildContext context) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Güvenlik kontrolü
      await TeamSecurity.validateTeamDataAccess(teamId,
          requiredRoles: ['admin']);

      // Ayarları doğrula
      if (settings.containsKey(FirebaseFields.name)) {
        settings[FirebaseFields.name] =
            TeamSecurity.sanitizeTeamInput(settings[FirebaseFields.name]);
      }

      // İşlemi çevrimdışı kuyruğa ekle
      await _sync.queueOperation(teamId, 'update', settings);

      // Önbelleği temizle
      _cache.invalidateCache(teamId);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      TeamErrorHandler.handleError(context, e);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> leaveTeam(String teamId, BuildContext context) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Güvenlik kontrolü
      await TeamSecurity.validateTeamDataAccess(teamId);

      final user = _auth.currentUser;
      if (user == null) {
        throw TeamPermissionException();
      }

      // Admin kontrolü
      final isAdmin =
          await TeamSecurity.validateTeamPermission(teamId, ['admin']);
      if (isAdmin) {
        throw TeamValidationException('Admin cannot leave the team');
      }

      // İşlemi çevrimdışı kuyruğa ekle
      await _sync.queueOperation(teamId, 'update', {
        FirebaseFields.memberCount: FieldValue.increment(-1),
      });

      // Üyeliği sil
      await _firestore
          .collection(FirebaseCollections.teamMembers)
          .doc(user.uid)
          .delete();

      // Kullanıcı bilgilerini güncelle
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .update({
        FirebaseFields.teamId: FieldValue.delete(),
        FirebaseFields.teamRole: FieldValue.delete(),
      });

      // Önbelleği temizle
      _cache.invalidateCache(teamId);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      TeamErrorHandler.handleError(context, e);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}

/// Takım işlem sonucu
class TeamOperationResult<T> {
  final bool success;
  final T? data;
  final TeamException? error;

  TeamOperationResult.success({required this.data})
      : success = true,
        error = null;

  TeamOperationResult.failure({required this.error})
      : success = false,
        data = null;
}

/// Takım işlemleri için özel hata sınıfı
class TeamException implements Exception {
  final String message;
  final TeamErrorType errorType;

  TeamException(this.message, {required this.errorType});

  @override
  String toString() => message;
}

/// Takım hata tipleri
enum TeamErrorType {
  invalidName,
  invalidReferralCode,
  userNotFound,
  userAlreadyInTeam,
  teamNotFound,
  teamFull,
  firebaseError,
  unknown,
}
