import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/task_details.dart';
import 'package:tuncbt/core/services/global_methods.dart';

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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      child: Dismissible(
        key: Key(taskId),
        background: _buildDismissibleBackground(),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await _showDeleteDialog(context);
        },
        onDismissed: (direction) {
          _deleteTask(context);
        },
        child: GestureDetector(
          onTap: () => _navigateToTaskDetails(context),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  _buildLeadingIcon(),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(),
                        SizedBox(height: 8.h),
                        _buildSubtitle(),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: 30.sp,
                    color: AppTheme.accentColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.w),
      color: Colors.red,
      child: Icon(Icons.delete, color: Colors.white, size: 30.sp),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? AppTheme.successColor : AppTheme.warningColor,
      ),
      child: Icon(
        isDone ? Icons.check : Icons.access_time,
        color: Colors.white,
        size: 24.sp,
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
        fontSize: 16.sp,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      taskDescription,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14.sp,
        color: AppTheme.secondaryColor,
      ),
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

  Future<bool> _showDeleteDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Delete Task',
                style: TextStyle(color: AppTheme.primaryColor)),
            content: Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Cancel',
                    style: TextStyle(color: AppTheme.secondaryColor)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8.w),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ) ??
        false;
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
    } catch (error) {
      GlobalMethod.showErrorDialog(
        error: 'This task cannot be deleted',
        context: context,
      );
    }
  }
}
