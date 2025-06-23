import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';
import '../models/team_member.dart';
import '../models/user_model.dart';
import '../enums/team_role.dart';
import '../constants/constants.dart';
import '../constants/firebase_constants.dart';
import 'referral_service.dart';

class TeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ReferralService _referralService = ReferralService();

  /// Yeni bir takım oluşturur
  Future<TeamOperationResult<Team>> createTeam({
    required String name,
    required String userId,
  }) async {
    try {
      // Takım adını doğrula
      final nameValidation = Team.validateTeamName(name);
      if (nameValidation != null) {
        return TeamOperationResult.failure(
          error: TeamException(
            nameValidation,
            errorType: TeamErrorType.invalidName,
          ),
        );
      }

      // Kullanıcının zaten bir takımı var mı kontrol et
      final userDoc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return TeamOperationResult.failure(
          error: TeamException(
            Constants.userNotFound,
            errorType: TeamErrorType.userNotFound,
          ),
        );
      }

      final userData = UserModel.fromFirestore(userDoc);
      if (userData.hasTeam) {
        return TeamOperationResult.failure(
          error: TeamException(
            Constants.userAlreadyInTeam,
            errorType: TeamErrorType.userAlreadyInTeam,
          ),
        );
      }

      // Benzersiz referral kodu oluştur
      final referralCode = await _referralService.generateUniqueCode();

      // Yeni takım oluştur
      final teamRef = _firestore.collection(FirebaseCollections.teams).doc();
      final now = DateTime.now();

      final team = Team(
        teamId: teamRef.id,
        teamName: name,
        referralCode: referralCode,
        createdBy: userId,
        createdAt: now,
        memberCount: 1,
        isActive: true,
      );

      // Takım ve takım üyesi kayıtlarını batch işlemle oluştur
      final batch = _firestore.batch();

      batch.set(teamRef, team.toJson());

      // İlk üyeyi ekle (kurucu)
      final memberRef =
          _firestore.collection(FirebaseCollections.teamMembers).doc();
      final member = TeamMember(
        teamId: teamRef.id,
        userId: userId,
        invitedBy: userId,
        joinedAt: now,
        role: TeamRole.admin,
      );

      batch.set(memberRef, member.toJson());

      // Kullanıcı bilgilerini güncelle
      batch.update(userDoc.reference, {
        FirebaseFields.teamId: teamRef.id,
        FirebaseFields.hasTeam: true,
        FirebaseFields.teamRole: TeamRole.admin.toString().split('.').last,
      });

      await batch.commit();
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
      // Referral kodu doğrula
      final validation = await _referralService.validateCode(referralCode);
      if (!validation.isValid) {
        return TeamOperationResult.failure(
          error: TeamException(
            validation.error!.message,
            errorType: TeamErrorType.invalidReferralCode,
          ),
        );
      }

      // Kullanıcıyı kontrol et
      final userDoc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return TeamOperationResult.failure(
          error: TeamException(
            Constants.userNotFound,
            errorType: TeamErrorType.userNotFound,
          ),
        );
      }

      final userData = UserModel.fromFirestore(userDoc);
      if (userData.hasTeam) {
        return TeamOperationResult.failure(
          error: TeamException(
            Constants.userAlreadyInTeam,
            errorType: TeamErrorType.userAlreadyInTeam,
          ),
        );
      }

      // Takımı bul
      final teamSnapshot = await _firestore
          .collection(FirebaseCollections.teams)
          .where(FirebaseFields.referralCode, isEqualTo: referralCode)
          .limit(1)
          .get();

      if (teamSnapshot.docs.isEmpty) {
        return TeamOperationResult.failure(
          error: TeamException(
            Constants.teamNotFound,
            errorType: TeamErrorType.teamNotFound,
          ),
        );
      }

      final teamDoc = teamSnapshot.docs.first;
      final team = Team.fromJson(teamDoc.data());

      // Takım kapasitesini kontrol et
      if (team.memberCount >= Constants.maxTeamSize) {
        return TeamOperationResult.failure(
          error: TeamException(
            Constants.teamFull,
            errorType: TeamErrorType.teamFull,
          ),
        );
      }

      // Batch işlemle üyelik oluştur
      final batch = _firestore.batch();
      final now = DateTime.now();

      // Yeni üye kaydı
      final memberRef =
          _firestore.collection(FirebaseCollections.teamMembers).doc();
      final member = TeamMember(
        teamId: team.teamId,
        userId: userId,
        invitedBy: team.createdBy,
        joinedAt: now,
        role: TeamRole.member,
      );

      batch.set(memberRef, member.toJson());

      // Takım üye sayısını güncelle
      batch.update(teamDoc.reference, {
        FirebaseFields.memberCount: FieldValue.increment(1),
      });

      // Kullanıcı bilgilerini güncelle
      batch.update(userDoc.reference, {
        FirebaseFields.teamId: team.teamId,
        FirebaseFields.hasTeam: true,
        FirebaseFields.teamRole: TeamRole.member.toString().split('.').last,
        FirebaseFields.invitedBy: team.createdBy,
      });

      await batch.commit();

      return TeamOperationResult.success(
        data: team.copyWith(memberCount: team.memberCount + 1),
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
      final snapshot = await _firestore
          .collection(FirebaseCollections.teamMembers)
          .where(FirebaseFields.teamId, isEqualTo: teamId)
          .where(FirebaseFields.isActive, isEqualTo: true)
          .get();

      final members =
          snapshot.docs.map((doc) => TeamMember.fromJson(doc.data())).toList();

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
