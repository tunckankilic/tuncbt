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
      'teamName': teamName,
      'referralCode': referralCode,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'memberCount': memberCount,
      'isActive': isActive,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      referralCode: json['referralCode'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      memberCount: json['memberCount'] as int,
      isActive: json['isActive'] as bool,
    );
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
}
