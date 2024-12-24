import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  String name;
  final String email;
  final String imageUrl;
  final String phoneNumber;
  final String position;
  final DateTime createdAt;
  final bool isOnline;

  UserModel({
    required this.id,
    this.isOnline = false,
    this.name = "No Name",
    required this.email,
    required this.imageUrl,
    required this.phoneNumber,
    required this.position,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      position: data['position'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isOnline: data["isOnline"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'position': position,
      'createdAt': Timestamp.fromDate(createdAt),
      "isOnline": isOnline,
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
    );
  }
}
