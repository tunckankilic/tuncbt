import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/team_role.dart';

class TeamMember {
  final String teamId;
  final String userId;
  final String? invitedBy;
  final DateTime joinedAt;
  final TeamRole role;
  final bool isActive;

  TeamMember({
    required this.teamId,
    required this.userId,
    this.invitedBy,
    required this.joinedAt,
    this.role = TeamRole.member,
    this.isActive = true,
  });

  factory TeamMember.empty() {
    return TeamMember(
      teamId: '',
      userId: '',
      invitedBy: null,
      joinedAt: DateTime.now(),
      role: TeamRole.member,
      isActive: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'userId': userId,
      'invitedBy': invitedBy,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'role': role.toString().split('.').last,
      'isActive': isActive,
    };
  }

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      teamId: json['teamId'] as String,
      userId: json['userId'] as String,
      invitedBy: json['invitedBy'] as String?,
      joinedAt: (json['joinedAt'] as Timestamp).toDate(),
      role: TeamRole.fromString(json['role'] as String),
      isActive: json['isActive'] as bool,
    );
  }

  TeamMember copyWith({
    String? teamId,
    String? userId,
    String? invitedBy,
    DateTime? joinedAt,
    TeamRole? role,
    bool? isActive,
  }) {
    return TeamMember(
      teamId: teamId ?? this.teamId,
      userId: userId ?? this.userId,
      invitedBy: invitedBy ?? this.invitedBy,
      joinedAt: joinedAt ?? this.joinedAt,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}
