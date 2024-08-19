import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuncbt/constants/constants.dart';
import 'package:tuncbt/screens/inner_screens/screens/task_details.dart';
import 'package:tuncbt/services/global_methods.dart';

class TaskWidget extends StatelessWidget {
  final String taskTitle;
  final String taskDescription;
  final String taskId;
  final String uploadedBy;
  final bool isDone;

  const TaskWidget({
    Key? key,
    required this.taskTitle,
    required this.taskDescription,
    required this.taskId,
    required this.uploadedBy,
    required this.isDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: () => _navigateToTaskDetails(context),
        onLongPress: () => _showDeleteDialog(context),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: _buildLeadingIcon(),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Colors.pink.shade800,
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      padding: const EdgeInsets.only(right: 12),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(width: 1)),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 20,
        child: Image.network(
          isDone
              ? 'https://image.flaticon.com/icons/png/128/390/390973.png'
              : 'https://image.flaticon.com/icons/png/128/850/850960.png',
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      taskTitle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Constants.darkBlue,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.linear_scale_outlined,
          color: Colors.pink.shade800,
        ),
        Text(
          taskDescription,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  void _navigateToTaskDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(
          taskID: taskId,
          uploadedBy: uploadedBy,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteTask(ctx),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (uploadedBy != user.uid) {
      GlobalMethod.showErrorDialog(
        error: 'You cannot perform this action',
        context: context,
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
      await Fluttertoast.showToast(
        msg: "Task has been deleted",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.grey,
        fontSize: 18.0,
      );
      Navigator.of(context).pop(); // Close the dialog
    } catch (error) {
      GlobalMethod.showErrorDialog(
        error: 'This task cannot be deleted',
        context: context,
      );
    }
  }
}
