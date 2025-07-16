import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/team_role.dart';

class UserModel {
  final String id;
  String name;
  final String email;
  final String imageUrl;
  final String phoneNumber;
  final String position;
  final DateTime createdAt;
  final bool isOnline;
  final String? teamId;
  final String? invitedBy;
  final TeamRole? teamRole;
  final bool hasTeam;

  UserModel({
    required this.id,
    this.isOnline = false,
    this.name = "No Name",
    required this.email,
    required this.imageUrl,
    required this.phoneNumber,
    required this.position,
    required this.createdAt,
    this.teamId,
    this.invitedBy,
    this.teamRole,
    this.hasTeam = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print('UserModel.fromFirestore - Raw data: $data');

    final teamRole = data['teamRole'];
    final hasTeam = data['hasTeam'] ?? false;
    final teamId = data['teamId'];

    print(
        'UserModel.fromFirestore - Team data: teamRole: $teamRole, hasTeam: $hasTeam, teamId: $teamId');

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      position: data['position'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isOnline: data["isOnline"] ?? false,
      teamId: teamId,
      invitedBy: data['invitedBy'],
      teamRole: teamRole != null ? TeamRole.fromString(teamRole) : null,
      hasTeam:
          hasTeam && teamId != null, // hasTeam sadece teamId varsa true olmalı
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      position: json['position'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      isOnline: json['isOnline'] ?? false,
      teamId: json['teamId'],
      invitedBy: json['invitedBy'],
      teamRole: json['teamRole'] != null
          ? TeamRole.fromString(json['teamRole'])
          : null,
      hasTeam: json['hasTeam'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'position': position,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isOnline': isOnline,
      'teamId': teamId,
      'invitedBy': invitedBy,
      'teamRole': teamRole?.toString().split('.').last.toLowerCase(),
      'hasTeam': hasTeam,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'position': position,
      'createdAt': Timestamp.fromDate(createdAt),
      "isOnline": isOnline,
      'teamId': teamId,
      'invitedBy': invitedBy,
      'teamRole': teamRole?.toString().split('.').last.toLowerCase(),
      'hasTeam': teamId != null, // hasTeam sadece teamId varsa true olmalı
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    String? phoneNumber,
    String? position,
    DateTime? createdAt,
    bool? isOnline,
    String? teamId,
    String? invitedBy,
    TeamRole? teamRole,
    bool? hasTeam,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
      teamId: teamId ?? this.teamId,
      invitedBy: invitedBy ?? this.invitedBy,
      teamRole: teamRole ?? this.teamRole,
      hasTeam: hasTeam ?? this.hasTeam,
    );
  }

  static UserModel empty() {
    return UserModel(
      id: '',
      name: '',
      email: '',
      imageUrl: '',
      phoneNumber: '',
      position: '',
      createdAt: DateTime.now(),
      isOnline: false,
      hasTeam: false,
    );
  }

  /// Mevcut kullanıcıları yeni yapıya geçirmek için yardımcı metod
  static Future<void> migrateExistingUsers() async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final QuerySnapshot snapshot = await usersRef.get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      final userData = doc.data() as Map<String, dynamic>;
      if (!userData.containsKey('hasTeam')) {
        batch.update(doc.reference, {
          'hasTeam': false,
          'teamRole': null,
          'teamId': null,
          'invitedBy': null,
        });
      }
    }
    await batch.commit();
  }
}
