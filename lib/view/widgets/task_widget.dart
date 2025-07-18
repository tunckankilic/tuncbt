import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/task_details.dart';
import 'package:tuncbt/core/services/global_methods.dart';
import 'package:tuncbt/core/models/user_model.dart';

class TaskWidget extends StatelessWidget {
  final String taskTitle;
  final String taskDescription;
  final String taskId;
  final String uploadedBy;
  final bool isDone;
  final String teamId;
  final bool isLargeTablet;

  const TaskWidget({
    Key? key,
    required this.taskTitle,
    required this.taskDescription,
    required this.taskId,
    required this.uploadedBy,
    required this.isDone,
    required this.teamId,
    this.isLargeTablet = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isLargeTablet
          ? EdgeInsets.all(16.0)
          : EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.r),
              child: Row(
                children: [
                  _buildLeadingIcon(isLargeTablet),
                  SizedBox(width: isLargeTablet ? 24.0 : 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(isLargeTablet),
                        SizedBox(height: isLargeTablet ? 12.0 : 8.h),
                        _buildSubtitle(isLargeTablet),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: isLargeTablet ? 36.0 : 30.sp,
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

  Widget _buildLeadingIcon(bool isLargeTablet) {
    return Container(
      width: isLargeTablet ? 60.0 : 50.w,
      height: isLargeTablet ? 60.0 : 50.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? AppTheme.successColor : AppTheme.warningColor,
      ),
      child: Icon(
        isDone ? Icons.check : Icons.access_time,
        color: Colors.white,
        size: isLargeTablet ? 28.0 : 24.sp,
      ),
    );
  }

  Widget _buildTitle(bool isLargeTablet) {
    return Text(
      taskTitle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: isLargeTablet ? 20.0 : 16.sp,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSubtitle(bool isLargeTablet) {
    return Text(
      taskDescription,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: isLargeTablet ? 16.0 : 14.sp,
        color: AppTheme.secondaryColor,
      ),
    );
  }

  void _navigateToTaskDetails(BuildContext context) {
    print(
        'TaskWidget: Görev detayına yönlendiriliyor - TaskID: $taskId, TeamID: $teamId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(
          taskID: taskId,
          uploadedBy: uploadedBy,
          teamId: teamId,
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.deleteTask,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: isLargeTablet ? 20.0 : 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              AppLocalizations.of(context)!.deleteTaskConfirm,
              style: TextStyle(
                fontSize: isLargeTablet ? 16.0 : 14.0,
              ),
            ),
            contentPadding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.0),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeTablet ? 20.0 : 16.0,
                    vertical: isLargeTablet ? 12.0 : 8.0,
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: isLargeTablet ? 16.0 : 14.0,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeTablet ? 20.0 : 16.0,
                    vertical: isLargeTablet ? 12.0 : 8.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: isLargeTablet ? 24.0 : 20.0,
                    ),
                    SizedBox(width: isLargeTablet ? 12.0 : 8.w),
                    Text(
                      AppLocalizations.of(context)!.delete,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: isLargeTablet ? 16.0 : 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteTask(BuildContext context) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        GlobalMethod.showErrorDialog(
          error: AppLocalizations.of(context)!.loginRequired,
          context: context,
        );
        return;
      }

      // Kullanıcının takım bilgilerini al
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        GlobalMethod.showErrorDialog(
          error: AppLocalizations.of(context)!.userNotFound,
          context: context,
        );
        return;
      }

      final userData = UserModel.fromFirestore(userDoc);

      // Takım kontrolü
      if (userData.teamId != teamId) {
        GlobalMethod.showErrorDialog(
          error: AppLocalizations.of(context)!.noPermissionToDelete,
          context: context,
        );
        return;
      }

      // Yetki kontrolü
      if (uploadedBy != user.uid &&
          userData.teamRole?.name != 'admin' &&
          userData.teamRole?.name != 'manager') {
        GlobalMethod.showErrorDialog(
          error: AppLocalizations.of(context)!.noPermissionToDelete,
          context: context,
        );
        return;
      }

      // Görevi sil
      await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('tasks')
          .doc(taskId)
          .delete();

      await Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.taskDeleted,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.grey,
        fontSize: isLargeTablet ? 20.0 : 18.0,
      );
    } catch (error) {
      GlobalMethod.showErrorDialog(
        error: AppLocalizations.of(context)!.taskDeleteError,
        context: context,
      );
    }
  }
}
