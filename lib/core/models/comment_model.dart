import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String userId;
  final String name;
  final String userImageUrl;
  final String body;
  final DateTime time;
  final String teamRole;

  CommentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.userImageUrl,
    required this.body,
    required this.time,
    required this.teamRole,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['commentId'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      userImageUrl: map['userImageUrl'] ?? '',
      body: map['commentBody'] ?? '',
      time: (map['time'] as Timestamp).toDate(),
      teamRole: map['teamRole'] ?? '',
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
      'teamRole': teamRole,
    };
  }

  CommentModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? userImageUrl,
    String? body,
    DateTime? time,
    String? teamRole,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      body: body ?? this.body,
      time: time ?? this.time,
      teamRole: teamRole ?? this.teamRole,
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
      teamRole: '',
    );
  }
}
