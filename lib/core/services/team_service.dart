import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/config/firebase_constants.dart';
import 'package:uuid/uuid.dart';
import '../models/team.dart';
import '../models/team_member.dart';
import '../models/user_model.dart';
import '../enums/team_role.dart';
import 'package:tuncbt/utils/team_errors.dart';
import 'package:tuncbt/utils/team_cache.dart';
import 'package:tuncbt/utils/team_security.dart';
import 'package:tuncbt/utils/team_sync.dart';
import 'package:tuncbt/core/services/referral_service.dart';

class TeamService extends GetxService {
  final errorMessage = ''.obs;
  final hasError = false.obs;
  final isLoading = false.obs;
  final maxTeamSize = 50;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _cache = Get.put(TeamCache());
  final _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _hasNetworkConnection = true;
  final _sync = Get.put(TeamSync());
  final _uuid = Uuid();

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
  }

  /// Yeni bir takım oluşturur
  Future<TeamOperationResult<Team>> createTeam(String name) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Kullanıcı kontrolü
      final user = _auth.currentUser;
      if (user == null) {
        throw TeamPermissionException();
      }

      // İsim doğrulama
      final sanitizedName = name.trim();
      final validationError = Team.validateTeamName(sanitizedName);
      if (validationError != null) {
        throw TeamValidationException(validationError);
      }

      // Kullanıcının takım durumunu kontrol et
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data()?['hasTeam'] == true) {
        throw TeamValidationException('Kullanıcı zaten bir takıma üye');
      }

      final now = DateTime.now();
      final teamId = _firestore.collection('teams').doc().id;

      // Takımı oluştur
      final team = Team(
        teamId: teamId,
        teamName: sanitizedName,
        createdBy: user.uid,
        memberCount: 1,
        createdAt: now,
        isActive: true,
      );

      // Takımı kaydet
      await _firestore.collection('teams').doc(teamId).set(team.toJson());

      // Referral kodu oluştur
      final referralService = ReferralService();
      final referralCode = await referralService.generateUniqueCode(
        teamId: teamId,
        userId: user.uid,
      );

      // Takımı referral kodu ile güncelle
      await _firestore.collection('teams').doc(teamId).update({
        'referralCode': referralCode,
      });

      // Kullanıcıyı takım yöneticisi olarak ekle
      await _firestore
          .collection('team_members')
          .doc('${teamId}_${user.uid}')
          .set({
        'userId': user.uid,
        'teamId': teamId,
        'role': TeamRole.admin.toString().split('.').last,
        'joinedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Kullanıcı bilgilerini güncelle
      await _firestore.collection('users').doc(user.uid).update({
        'hasTeam': true,
        'teamId': teamId,
        'teamRole': TeamRole.admin.toString().split('.').last,
      });

      // Önbelleğe ekle
      _cache.cacheTeam(teamId, team);

      print('TeamService: Takım başarıyla oluşturuldu: ${team.toJson()}');
      return TeamOperationResult.success(data: team);
    } on FirebaseException catch (e, stackTrace) {
      print('TeamService: Firebase hatası: ${e.code} - ${e.message}');
      print('Stack trace: $stackTrace');
      return TeamOperationResult.failure(
        error: TeamException(
          FirebaseErrorCodes.getErrorMessage(e.code),
          errorType: TeamErrorType.firebaseError,
        ),
      );
    } catch (e, stackTrace) {
      print('TeamService: Beklenmeyen hata: $e');
      print('Stack trace: $stackTrace');
      return TeamOperationResult.failure(
        error: TeamException(
          'Beklenmeyen bir hata oluştu: $e',
          errorType: TeamErrorType.unknown,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Bir takıma katılma işlemi
  Future<TeamOperationResult<Team>> joinTeam({
    required String referralCode,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Kullanıcı kontrolü
      final user = _auth.currentUser;
      if (user == null) {
        throw TeamPermissionException();
      }

      // Referral kodu doğrula
      final referralService = ReferralService();
      final validationResult = await referralService.validateCode(referralCode);

      if (!validationResult.isValid || validationResult.teamId == null) {
        throw TeamValidationException(
          validationResult.error?.message ?? 'Geçersiz referral kodu',
        );
      }

      final teamId = validationResult.teamId!;

      // Takım kontrolü
      final teamDoc = await _firestore.collection('teams').doc(teamId).get();
      if (!teamDoc.exists) {
        throw TeamValidationException('Takım bulunamadı');
      }

      // Kapasite kontrolü
      final memberCount = teamDoc.data()?['memberCount'] ?? 0;
      if (memberCount >= maxTeamSize) {
        throw TeamCapacityException();
      }

      // Referral kodunu kullan
      await referralService.useCode(referralCode, user.uid);

      // Takım üyeliğini oluştur
      await _firestore
          .collection('team_members')
          .doc('${teamId}_${user.uid}')
          .set({
        'userId': user.uid,
        'teamId': teamId,
        'role': TeamRole.member.toString().split('.').last,
        'joinedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'invitedBy': validationResult.createdBy,
      });

      // Kullanıcı bilgilerini güncelle
      await _firestore.collection('users').doc(user.uid).update({
        'hasTeam': true,
        'teamId': teamId,
        'teamRole': TeamRole.member.toString().split('.').last,
        'invitedBy': validationResult.createdBy,
      });

      // Takım üye sayısını güncelle
      await _firestore.collection('teams').doc(teamId).update({
        'memberCount': FieldValue.increment(1),
      });

      // Önbelleği temizle
      _cache.invalidateCache(teamId);

      final team = Team.fromFirestore(teamDoc);
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
          e.toString(),
          errorType: TeamErrorType.unknown,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Takım bilgilerini getirir
  Future<TeamOperationResult<Team>> getTeamInfo(String teamId) async {
    try {
      print('TeamService: Takım bilgileri alınıyor... Team ID: $teamId');

      final doc = await _firestore
          .collection(FirebaseCollections.teams)
          .doc(teamId)
          .get();

      print(
          'TeamService: Firestore dokümanı alındı. Exists: ${doc.exists}, Data: ${doc.data()}');

      if (!doc.exists) {
        print('TeamService: Takım dokümanı bulunamadı');
        return TeamOperationResult.failure(
          error: TeamException(
            'Takım bulunamadı',
            errorType: TeamErrorType.teamNotFound,
          ),
        );
      }

      final data = Map<String, dynamic>.from(doc.data()!);
      data['teamId'] = doc.id; // teamId'yi ekle

      try {
        final team = Team.fromFirestore(doc);
        print('TeamService: Takım nesnesi oluşturuldu: $team');
        return TeamOperationResult.success(data: team);
      } catch (e, stackTrace) {
        print('TeamService: Takım nesnesi oluşturulurken hata: $e');
        print('Stack trace: $stackTrace');
        return TeamOperationResult.failure(
          error: TeamException(
            'Takım verisi geçersiz: $e',
            errorType: TeamErrorType.unknown,
          ),
        );
      }
    } on FirebaseException catch (e, stackTrace) {
      print('TeamService: Firebase hatası: ${e.code} - ${e.message}');
      print('Stack trace: $stackTrace');
      return TeamOperationResult.failure(
        error: TeamException(
          FirebaseErrorCodes.getErrorMessage(e.code),
          errorType: TeamErrorType.firebaseError,
        ),
      );
    } catch (e, stackTrace) {
      print('TeamService: Beklenmeyen hata: $e');
      print('Stack trace: $stackTrace');
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
      String teamId) async {
    try {
      print('TeamService: Takım üyeleri alınıyor... TeamID: $teamId');

      // Önce kullanıcının takıma ait olup olmadığını kontrol et
      final user = _auth.currentUser;
      if (user == null) {
        return TeamOperationResult.failure(
          error: TeamException(
            'Kullanıcı oturumu bulunamadı',
            errorType: TeamErrorType.userNotFound,
          ),
        );
      }

      // Kullanıcı dokümanını kontrol et
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        return TeamOperationResult.failure(
          error: TeamException(
            'Kullanıcı bilgileri bulunamadı',
            errorType: TeamErrorType.userNotFound,
          ),
        );
      }

      final userData = userDoc.data()!;
      final userTeamId = userData['teamId'] as String?;

      // Takım ID'si eşleşmiyor
      if (userTeamId != teamId) {
        return TeamOperationResult.failure(
          error: TeamException(
            'Bu takıma erişim yetkiniz yok',
            errorType: TeamErrorType.teamNotFound,
          ),
        );
      }

      // Önbellekten kontrol et
      final cachedMembers = await _cache.getTeamMembers(teamId);
      if (cachedMembers != null) {
        return TeamOperationResult.success(data: cachedMembers);
      }

      // Veritabanından yükle - Sadece teamId ile sorgula
      final query = _firestore
          .collection('team_members')
          .where('teamId', isEqualTo: teamId);

      final membersSnapshot = await query.get();

      if (membersSnapshot.docs.isEmpty) {
        return TeamOperationResult.failure(
          error: TeamException(
            'Takım üyeleri bulunamadı',
            errorType: TeamErrorType.teamNotFound,
          ),
        );
      }

      // Bellek içinde filtreleme ve sıralama yap
      final filteredDocs = membersSnapshot.docs
          .where((doc) => doc.data()['isActive'] == true)
          .toList()
        ..sort((a, b) {
          final aTime = (a.data()['joinedAt'] as Timestamp).toDate();
          final bTime = (b.data()['joinedAt'] as Timestamp).toDate();
          return aTime.compareTo(bTime);
        });

      if (filteredDocs.length > maxTeamSize) {
        filteredDocs.length = maxTeamSize;
      }

      final members = await Future.wait(
        filteredDocs.map((doc) async {
          final data = doc.data();
          if (!data.containsKey('role') || !data.containsKey('joinedAt')) {
            throw TeamException(
              'Üye verisi eksik',
              errorType: TeamErrorType.unknown,
            );
          }

          final userId = doc.id.split('_').last;
          final userData =
              await _firestore.collection('users').doc(userId).get();

          // Role dönüşümü
          final roleStr = data['role'] as String? ??
              TeamRole.member.toString().split('.').last;
          final role = TeamRole.values.firstWhere(
            (e) =>
                e.toString().split('.').last.toLowerCase() ==
                roleStr.toLowerCase(),
            orElse: () => TeamRole.member,
          );

          print(
              'TeamService: Üye rolü dönüştürülüyor - RoleStr: $roleStr, Role: $role');

          return TeamMember(
            userId: userId,
            teamId: teamId,
            role: role,
            joinedAt: (data['joinedAt'] as Timestamp).toDate(),
            invitedBy: userData.data()?['invitedBy'],
          );
        }),
      );

      // Önbelleğe ekle
      _cache.cacheTeamMembers(teamId, members);

      print(
          'TeamService: Takım üyeleri başarıyla yüklendi. Üye sayısı: ${members.length}');
      return TeamOperationResult.success(data: members);
    } on FirebaseException catch (e, stackTrace) {
      print('TeamService: Firebase hatası: ${e.code} - ${e.message}');
      print('Stack trace: $stackTrace');
      return TeamOperationResult.failure(
        error: TeamException(
          FirebaseErrorCodes.getErrorMessage(e.code),
          errorType: TeamErrorType.firebaseError,
        ),
      );
    } catch (e, stackTrace) {
      print('TeamService: Beklenmeyen hata: $e');
      print('Stack trace: $stackTrace');
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
    return _handleOperation(() async {
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
    }, context);
  }

  Future<void> leaveTeam(String teamId, BuildContext context) async {
    return _handleOperation(() async {
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
    }, context);
  }

  /// Kullanıcının takım verilerini temizler
  Future<TeamOperationResult<void>> cleanUserTeamData(String userId) async {
    try {
      print(
          'TeamService: Kullanıcı takım verilerini temizleme başlatıldı. UserID: $userId');

      // Kullanıcının mevcut takım bilgilerini al
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return TeamOperationResult.failure(
          error: TeamException(
            'Kullanıcı bulunamadı',
            errorType: TeamErrorType.userNotFound,
          ),
        );
      }

      final userData = userDoc.data()!;
      final oldTeamId = userData['teamId'] as String?;

      // Batch işlemi başlat
      final batch = _firestore.batch();

      // 1. Kullanıcı dokümanını güncelle
      batch.update(_firestore.collection('users').doc(userId), {
        'teamId': null,
        'teamRole': null,
        'hasTeam': false,
        'invitedBy': null,
      });

      // 2. Eğer eski takım ID'si varsa, takım üyeliğini sil
      if (oldTeamId != null) {
        final memberDoc =
            _firestore.collection('team_members').doc('${oldTeamId}_$userId');
        batch.delete(memberDoc);

        // 3. Takımın üye sayısını güncelle
        batch.update(_firestore.collection('teams').doc(oldTeamId), {
          'memberCount': FieldValue.increment(-1),
        });
      }

      // Batch işlemini uygula
      await batch.commit();

      print('TeamService: Kullanıcı takım verileri başarıyla temizlendi');
      return TeamOperationResult.success(data: null);
    } on FirebaseException catch (e, stackTrace) {
      print('TeamService: Firebase hatası: ${e.code} - ${e.message}');
      print('Stack trace: $stackTrace');
      return TeamOperationResult.failure(
        error: TeamException(
          FirebaseErrorCodes.getErrorMessage(e.code),
          errorType: TeamErrorType.firebaseError,
        ),
      );
    } catch (e, stackTrace) {
      print('TeamService: Beklenmeyen hata: $e');
      print('Stack trace: $stackTrace');
      return TeamOperationResult.failure(
        error: TeamException(
          'Beklenmeyen bir hata oluştu: $e',
          errorType: TeamErrorType.unknown,
        ),
      );
    }
  }

  /// Takım üyeliği kaydını oluşturur veya günceller
  Future<TeamOperationResult<void>> ensureTeamMembership({
    required String teamId,
    required String userId,
    required TeamRole role,
  }) async {
    try {
      print(
          'TeamService: Takım üyeliği kontrol ediliyor... TeamID: $teamId, UserID: $userId');

      final memberDocId = '${teamId}_$userId';
      final memberRef = _firestore.collection('team_members').doc(memberDocId);

      // Batch işlemi başlat
      final batch = _firestore.batch();

      // Üyelik dokümanını oluştur/güncelle
      batch.set(
          memberRef,
          {
            'teamId': teamId,
            'userId': userId,
            'role': role.toString().split('.').last.toLowerCase(),
            'joinedAt': FieldValue.serverTimestamp(),
            'isActive': true,
          },
          SetOptions(merge: true));

      // Kullanıcı dokümanını güncelle
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'teamId': teamId,
        'teamRole': role.toString().split('.').last.toLowerCase(),
        'hasTeam': true,
      });

      // Takım dokümanını güncelle
      final teamRef = _firestore.collection('teams').doc(teamId);
      batch.update(teamRef, {
        'memberCount': FieldValue.increment(1),
      });

      // Batch işlemini uygula
      await batch.commit();

      print('TeamService: Takım üyeliği başarıyla güncellendi');

      // Önbelleği temizle
      _cache.invalidateCache(teamId);

      return TeamOperationResult.success(data: null);
    } on FirebaseException catch (e, stackTrace) {
      print('TeamService: Firebase hatası: ${e.code} - ${e.message}');
      print('Stack trace: $stackTrace');
      return TeamOperationResult.failure(
        error: TeamException(
          FirebaseErrorCodes.getErrorMessage(e.code),
          errorType: TeamErrorType.firebaseError,
        ),
      );
    } catch (e, stackTrace) {
      print('TeamService: Beklenmeyen hata: $e');
      print('Stack trace: $stackTrace');
      return TeamOperationResult.failure(
        error: TeamException(
          'Beklenmeyen bir hata oluştu: $e',
          errorType: TeamErrorType.unknown,
        ),
      );
    }
  }

  /// Takım üyeliğini kontrol eder ve gerekirse oluşturur
  Future<TeamOperationResult<void>> checkAndCreateTeamMembership() async {
    try {
      print('TeamService: Takım üyeliği kontrol ediliyor...');

      // Kullanıcı kontrolü
      final user = _auth.currentUser;
      if (user == null) {
        throw TeamPermissionException();
      }

      // Kullanıcı verilerini al
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw TeamException(
          'Kullanıcı bilgileri bulunamadı',
          errorType: TeamErrorType.userNotFound,
        );
      }

      final userData = UserModel.fromFirestore(userDoc);
      print(
          'TeamService: Kullanıcı verileri alındı: ${userData.toFirestore()}');

      // Takım ID'si kontrolü
      if (userData.teamId == null || !userData.hasTeam) {
        throw TeamException(
          'Kullanıcı bir takıma ait değil',
          errorType: TeamErrorType.teamNotFound,
        );
      }

      // Takım üyeliği kontrolü
      final memberDocId = '${userData.teamId}_${user.uid}';
      final memberDoc =
          await _firestore.collection('team_members').doc(memberDocId).get();

      // Üyelik yoksa veya aktif değilse oluştur
      if (!memberDoc.exists || !(memberDoc.data()?['isActive'] ?? false)) {
        print(
            'TeamService: Takım üyeliği bulunamadı veya aktif değil. Oluşturuluyor...');

        await ensureTeamMembership(
          teamId: userData.teamId!,
          userId: user.uid,
          role: userData.teamRole ?? TeamRole.member,
        );

        print('TeamService: Takım üyeliği oluşturuldu');
      } else {
        print('TeamService: Takım üyeliği mevcut ve aktif');
      }

      return TeamOperationResult.success(data: null);
    } on FirebaseException catch (e, stackTrace) {
      print('TeamService: Firebase hatası: ${e.code} - ${e.message}');
      print('Stack trace: $stackTrace');
      return TeamOperationResult.failure(
        error: TeamException(
          FirebaseErrorCodes.getErrorMessage(e.code),
          errorType: TeamErrorType.firebaseError,
        ),
      );
    } catch (e, stackTrace) {
      print('TeamService: Beklenmeyen hata: $e');
      print('Stack trace: $stackTrace');
      return TeamOperationResult.failure(
        error: TeamException(
          'Beklenmeyen bir hata oluştu: $e',
          errorType: TeamErrorType.unknown,
        ),
      );
    }
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
}

/// Takım işlem sonucu
class TeamOperationResult<T> {
  TeamOperationResult.failure({required this.error})
      : success = false,
        data = null;

  TeamOperationResult.success({required this.data})
      : success = true,
        error = null;

  final T? data;
  final TeamException? error;
  final bool success;
}

/// Takım işlemleri için özel hata sınıfı
class TeamException implements Exception {
  TeamException(this.message, {required this.errorType});

  final TeamErrorType errorType;
  final String message;

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
