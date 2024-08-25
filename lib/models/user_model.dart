import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String userImage;
  final String phoneNumber;
  final String positionInCompany;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userImage,
    required this.phoneNumber,
    required this.positionInCompany,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      userImage: data['userImage'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      positionInCompany: data['positionInCompany'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userImage': userImage,
      'phoneNumber': phoneNumber,
      'positionInCompany': positionInCompany,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? userImage,
    String? phoneNumber,
    String? positionInCompany,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userImage: userImage ?? this.userImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      positionInCompany: positionInCompany ?? this.positionInCompany,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static UserModel empty() {
    return UserModel(
      id: '',
      name: '',
      email: '',
      userImage: '',
      phoneNumber: '',
      positionInCompany: '',
      createdAt: DateTime.now(),
    );
  }
}
