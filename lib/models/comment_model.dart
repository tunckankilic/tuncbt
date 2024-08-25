import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String userId;
  final String name;
  final String userImageUrl;
  final String body;
  final DateTime time;

  CommentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.userImageUrl,
    required this.body,
    required this.time,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['commentId'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      userImageUrl: map['userImageUrl'] ?? '',
      body: map['commentBody'] ?? '',
      time: (map['time'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': id,
      'userId': userId,
      'name': name,
      'userImageUrl': userImageUrl,
      'commentBody': body,
      'time': Timestamp.fromDate(time),
    };
  }

  CommentModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? userImageUrl,
    String? body,
    DateTime? time,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      body: body ?? this.body,
      time: time ?? this.time,
    );
  }

  static CommentModel empty() {
    return CommentModel(
      id: '',
      userId: '',
      name: '',
      userImageUrl: '',
      body: '',
      time: DateTime.now(),
    );
  }
}
