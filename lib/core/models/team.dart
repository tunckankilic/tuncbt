import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class Team {
  final String teamId;
  final String teamName;
  final String? referralCode;
  final String createdBy;
  final DateTime createdAt;
  final int memberCount;
  final bool isActive;

  Team({
    required this.teamId,
    required this.teamName,
    this.referralCode,
    required this.createdBy,
    required this.createdAt,
    this.memberCount = 1,
    this.isActive = true,
  });

  // Generate a unique 8-character referral code
  static String generateReferralCode(String teamName, String createdBy) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final input = '$teamName-$createdBy-$timestamp';
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    return hash.toString().substring(0, 8).toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'name': teamName,
      'referralCode': referralCode,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'memberCount': memberCount,
      'isActive': isActive,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    try {
      print('Team.fromJson başlatılıyor... Data: $json');

      // createdAt alanını DateTime'a çevir
      DateTime createdAtDate;
      final createdAtValue = json['createdAt'];
      if (createdAtValue is Timestamp) {
        createdAtDate = createdAtValue.toDate();
      } else if (createdAtValue is DateTime) {
        createdAtDate = createdAtValue;
      } else {
        throw FormatException('Invalid createdAt format: $createdAtValue');
      }

      // name alanını kontrol et (Firestore'da 'name' olarak saklanıyor)
      final name = json['name'];
      if (name == null || (name is String && name.trim().isEmpty)) {
        throw FormatException(
            'Team name is required. Available fields: ${json.keys.join(", ")}');
      }

      // createdBy alanını kontrol et
      final createdBy = json['createdBy'];
      if (createdBy == null ||
          (createdBy is String && createdBy.trim().isEmpty)) {
        throw FormatException('createdBy is required');
      }

      // memberCount'u kontrol et
      final memberCount = json['memberCount'];
      int parsedMemberCount = 1;
      if (memberCount != null) {
        if (memberCount is int) {
          parsedMemberCount = memberCount;
        } else if (memberCount is num) {
          parsedMemberCount = memberCount.toInt();
        }
      }

      final team = Team(
        teamId: json['teamId'] as String? ?? '',
        teamName: name as String,
        referralCode: json['referralCode'] as String?,
        createdBy: createdBy as String,
        createdAt: createdAtDate,
        memberCount: parsedMemberCount,
        isActive: json['isActive'] as bool? ?? true,
      );

      print('Team.fromJson başarılı: ${team.toJson()}');
      return team;
    } catch (e, stackTrace) {
      print('Team.fromJson error: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  Team copyWith({
    String? teamId,
    String? teamName,
    String? referralCode,
    String? createdBy,
    DateTime? createdAt,
    int? memberCount,
    bool? isActive,
  }) {
    return Team(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      referralCode: referralCode ?? this.referralCode,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
      isActive: isActive ?? this.isActive,
    );
  }

  // Validation method
  static String? validateTeamName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Takım adı boş olamaz';
    }
    if (value.length < 3) {
      return 'Takım adı en az 3 karakter olmalıdır';
    }
    if (value.length > 50) {
      return 'Takım adı en fazla 50 karakter olabilir';
    }
    return null;
  }

  static Team empty() {
    return Team(
      teamId: '',
      teamName: '',
      createdBy: '',
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Team{teamId: $teamId, teamName: $teamName, referralCode: $referralCode, createdBy: $createdBy, createdAt: $createdAt, memberCount: $memberCount, isActive: $isActive}';
  }
}
