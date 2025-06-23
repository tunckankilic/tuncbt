import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncbt/core/models/comment_model.dart';

class TaskModel {
  final String id;
  final String uploadedBy;
  final String title;
  final String description;
  final DateTime deadline;
  final String deadlineDate;
  final String category;
  final List<CommentModel> comments;
  bool isDone;
  final DateTime createdAt;
  final String teamId;

  TaskModel({
    required this.id,
    required this.uploadedBy,
    required this.title,
    required this.description,
    required this.deadline,
    required this.deadlineDate,
    required this.category,
    this.comments = const [],
    this.isDone = false,
    required this.createdAt,
    required this.teamId,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      uploadedBy: data['uploadedBy'] ?? '',
      title: data['taskTitle'] ?? '',
      description: data['taskDescription'] ?? '',
      deadline: (data['deadlineDateTimeStamp'] as Timestamp).toDate(),
      deadlineDate: data['deadlineDate'] ?? '',
      category: data['taskCategory'] ?? '',
      comments: (data['taskComments'] as List<dynamic>?)
              ?.map((comment) => CommentModel.fromMap(comment))
              .toList() ??
          [],
      isDone: data['isDone'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      teamId: data['teamId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'taskId': id,
      'uploadedBy': uploadedBy,
      'taskTitle': title,
      'taskDescription': description,
      'deadlineDateTimeStamp': Timestamp.fromDate(deadline),
      'deadlineDate': deadlineDate,
      'taskCategory': category,
      'taskComments': comments.map((comment) => comment.toMap()).toList(),
      'isDone': isDone,
      'createdAt': Timestamp.fromDate(createdAt),
      'teamId': teamId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? uploadedBy,
    String? title,
    String? description,
    DateTime? deadline,
    String? deadlineDate,
    String? category,
    List<CommentModel>? comments,
    bool? isDone,
    DateTime? createdAt,
    String? teamId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      category: category ?? this.category,
      comments: comments ?? this.comments,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      teamId: teamId ?? this.teamId,
    );
  }

  static TaskModel empty() {
    return TaskModel(
      id: '',
      uploadedBy: '',
      title: '',
      description: '',
      deadline: DateTime.now(),
      deadlineDate: '',
      category: '',
      comments: [],
      isDone: false,
      createdAt: DateTime.now(),
      teamId: '',
    );
  }
}
