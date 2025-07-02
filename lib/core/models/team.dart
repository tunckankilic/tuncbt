import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'name': teamName,
      'referralCode': referralCode,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'memberCount': memberCount,
      'isActive': isActive,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      teamId: json['teamId'] ?? '',
      teamName: json['name'] ?? '',
      referralCode: json['referralCode'],
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      memberCount: json['memberCount'] ?? 1,
      isActive: json['isActive'] ?? true,
    );
  }

  factory Team.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Team(
      teamId: doc.id,
      teamName: data['name'] ?? '',
      referralCode: data['referralCode'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      memberCount: data['memberCount'] ?? 1,
      isActive: data['isActive'] ?? true,
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
