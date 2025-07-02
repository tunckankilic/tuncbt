import 'package:cloud_firestore/cloud_firestore.dart';

class ChatGroup {
  final String id;
  final String name;
  final String imageUrl;
  final String createdBy;
  final DateTime createdAt;
  final List<String> members;
  final List<String> admins;
  final String? description;
  final Map<String, int> unreadCounts; // userId -> unreadCount

  ChatGroup({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.createdBy,
    required this.createdAt,
    required this.members,
    required this.admins,
    this.description,
    required this.unreadCounts,
  });

  factory ChatGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatGroup(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      members: List<String>.from(data['members'] ?? []),
      admins: List<String>.from(data['admins'] ?? []),
      description: data['description'],
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'members': members,
      'admins': admins,
      'description': description,
      'unreadCounts': unreadCounts,
    };
  }

  bool isAdmin(String userId) => admins.contains(userId);
  bool isMember(String userId) => members.contains(userId);
}
