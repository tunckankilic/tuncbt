import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncbt/utils/team_errors.dart';

class TeamSecurity {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Kullanıcının takıma ait olup olmadığını kontrol eder
  static Future<bool> validateTeamMembership(String teamId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw TeamPermissionException();
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.data()?['teamId'] == teamId;
  }

  /// Kullanıcının takımdaki yetkisini kontrol eder
  static Future<bool> validateTeamPermission(
      String teamId, List<String> allowedRoles) async {
    try {
      print(
          'TeamSecurity: Yetki kontrolü başlatılıyor... TeamID: $teamId, AllowedRoles: $allowedRoles');

      final user = _auth.currentUser;
      if (user == null) {
        print('TeamSecurity: Kullanıcı oturumu bulunamadı');
        throw TeamPermissionException();
      }

      // Kullanıcı dokümanından rol bilgisini al
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        print('TeamSecurity: Kullanıcı dokümanı bulunamadı');
        return false;
      }

      final userData = userDoc.data()!;
      final userTeamId = userData['teamId'] as String?;
      final userRole = userData['teamRole'] as String?;

      print(
          'TeamSecurity: Kullanıcı verileri - TeamID: $userTeamId, Role: $userRole');

      // Takım ID'si eşleşmiyor
      if (userTeamId != teamId) {
        print('TeamSecurity: Takım ID uyuşmazlığı');
        return false;
      }

      // Rol kontrolü
      if (userRole == null) {
        print('TeamSecurity: Kullanıcı rolü bulunamadı');
        return false;
      }

      // Rol eşleşmesi kontrolü (case-insensitive)
      final hasPermission = allowedRoles
          .any((role) => role.toLowerCase() == userRole.toLowerCase());

      print(
          'TeamSecurity: Yetki kontrolü sonucu - HasPermission: $hasPermission');
      return hasPermission;
    } catch (e, stackTrace) {
      print('TeamSecurity Error: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Takım adı ve kodları için güvenlik kontrolü
  static String sanitizeTeamInput(String input) {
    // Özel karakterleri temizle
    final sanitized = input.replaceAll(RegExp(r'[^\w\s-]'), '');

    // Maksimum uzunluğu kontrol et
    if (sanitized.length > 50) {
      throw TeamValidationException('Team name or code is too long');
    }

    // Minimum uzunluğu kontrol et
    if (sanitized.length < 3) {
      throw TeamValidationException('Team name or code is too short');
    }

    return sanitized.trim();
  }

  /// Sorgu güvenliği için takım ID kontrolü
  static Query<Map<String, dynamic>> secureTeamQuery(
      Query<Map<String, dynamic>> query, String teamId) {
    return query.where('teamId', isEqualTo: teamId);
  }

  /// Çapraz takım veri sızıntısını önle
  static Future<void> preventCrossTeamAccess(String targetTeamId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw TeamPermissionException();
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userTeamId = userDoc.data()?['teamId'];

    if (userTeamId != targetTeamId) {
      throw TeamPermissionException();
    }
  }

  /// Takım verilerine erişim için güvenlik kontrolü
  static Future<void> validateTeamDataAccess(String teamId,
      {List<String>? requiredRoles}) async {
    try {
      print(
          'TeamSecurity: Veri erişim kontrolü başlatılıyor... TeamID: $teamId, RequiredRoles: $requiredRoles');

      await preventCrossTeamAccess(teamId);

      if (requiredRoles != null && requiredRoles.isNotEmpty) {
        print(
            'TeamSecurity: Rol kontrolü yapılıyor... RequiredRoles: $requiredRoles');
        final hasPermission =
            await validateTeamPermission(teamId, requiredRoles);
        if (!hasPermission) {
          print('TeamSecurity: Yetkisiz erişim');
          throw TeamPermissionException();
        }
      }

      print('TeamSecurity: Veri erişim kontrolü başarılı');
    } catch (e, stackTrace) {
      print('TeamSecurity Error: $e');
      print('Stack trace: $stackTrace');
      throw TeamPermissionException();
    }
  }
}
