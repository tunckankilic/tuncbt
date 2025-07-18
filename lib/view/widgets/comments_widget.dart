import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/core/models/comment_model.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/inner_screens/inner_screen_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentWidget extends StatelessWidget {
  final String commentId;
  final String commenterId;
  final String commenterName;
  final String commentBody;
  final String commenterImageUrl;
  final String commenterTeamRole;
  final DateTime commentTime;
  final bool isLargeTablet;

  const CommentWidget({
    Key? key,
    required this.commentId,
    required this.commenterId,
    required this.commenterName,
    required this.commentBody,
    required this.commenterImageUrl,
    required this.commenterTeamRole,
    required this.commentTime,
    required this.isLargeTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('CommentWidget oluşturuluyor');
    print('Comment ID: $commentId');
    print('Commenter Name: $commenterName');
    print('Comment Body: $commentBody');

    final controller = Get.find<InnerScreenController>();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCommentOwner = currentUserId == commenterId;

    print('Yorum sahibi mi: $isCommentOwner');

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(
        vertical: isLargeTablet ? 12.0 : 8.h,
        horizontal: isLargeTablet ? 24.0 : 16.w,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeTablet ? 20.0 : 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isLargeTablet ? 28.0 : 20.r,
                  backgroundImage: NetworkImage(
                    commenterImageUrl.isEmpty
                        ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'
                        : commenterImageUrl,
                  ),
                ),
                SizedBox(width: isLargeTablet ? 16.0 : 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                commenterName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isLargeTablet ? 18.0 : 14.sp,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              Text(
                                commenterTeamRole,
                                style: TextStyle(
                                  fontSize: isLargeTablet ? 16.0 : 12.sp,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                          if (isCommentOwner)
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  controller.startEditingComment(
                                    CommentModel(
                                      id: commentId,
                                      userId: commenterId,
                                      name: commenterName,
                                      userImageUrl: commenterImageUrl,
                                      body: commentBody,
                                      time: commentTime,
                                      teamRole: commenterTeamRole,
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  _showDeleteDialog(context, controller);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: isLargeTablet ? 24.0 : 18.sp,
                                      ),
                                      SizedBox(
                                          width: isLargeTablet ? 12.0 : 8.w),
                                      Text(
                                        AppLocalizations.of(context)!.edit,
                                        style: TextStyle(
                                          fontSize: isLargeTablet ? 16.0 : 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: isLargeTablet ? 24.0 : 18.sp,
                                        color: Colors.red,
                                      ),
                                      SizedBox(
                                          width: isLargeTablet ? 12.0 : 8.w),
                                      Text(
                                        AppLocalizations.of(context)!.delete,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: isLargeTablet ? 16.0 : 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Obx(() {
                        if (controller.isEditingComment.value &&
                            controller.editingCommentId.value == commentId) {
                          return Column(
                            children: [
                              TextField(
                                controller: controller.editCommentController,
                                maxLines: null,
                                style: TextStyle(
                                  fontSize: isLargeTablet ? 16.0 : 14.0,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Yorumu düzenle...',
                                  hintStyle: TextStyle(
                                    fontSize: isLargeTablet ? 16.0 : 14.0,
                                  ),
                                  contentPadding: EdgeInsets.all(
                                    isLargeTablet ? 16.0 : 12.0,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      isLargeTablet ? 12.0 : 8.r,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isLargeTablet ? 16.0 : 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        controller.cancelEditingComment(),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isLargeTablet ? 20.0 : 16.0,
                                        vertical: isLargeTablet ? 12.0 : 8.0,
                                      ),
                                    ),
                                    child: Text(
                                      'İptal',
                                      style: TextStyle(
                                        fontSize: isLargeTablet ? 16.0 : 14.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isLargeTablet ? 16.0 : 8.w),
                                  ElevatedButton(
                                    onPressed: () =>
                                        controller.updateComment(commentId),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isLargeTablet ? 24.0 : 16.0,
                                        vertical: isLargeTablet ? 16.0 : 12.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          isLargeTablet ? 12.0 : 8.r,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Kaydet',
                                      style: TextStyle(
                                        fontSize: isLargeTablet ? 16.0 : 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isLargeTablet ? 20.0 : 12.w),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(
                                isLargeTablet ? 12.0 : 8.r),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              width: isLargeTablet ? 2.0 : 1.0,
                            ),
                          ),
                          child: Text(
                            commentBody,
                            style: TextStyle(
                              fontSize: isLargeTablet ? 16.0 : 14.sp,
                              color: AppTheme.textColor,
                              height: 1.5,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isLargeTablet ? 16.0 : 8.h),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _getTimeAgo(commentTime),
                style: TextStyle(
                  fontSize: isLargeTablet ? 14.0 : 12.sp,
                  color: AppTheme.lightTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, InnerScreenController controller) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.deleteComment,
          style: TextStyle(
            fontSize: isLargeTablet ? 20.0 : 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteCommentConfirm,
          style: TextStyle(
            fontSize: isLargeTablet ? 16.0 : 14.0,
          ),
        ),
        contentPadding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeTablet ? 20.0 : 16.0,
                vertical: isLargeTablet ? 12.0 : 8.0,
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                fontSize: isLargeTablet ? 16.0 : 14.0,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteComment(commentId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: EdgeInsets.symmetric(
                horizontal: isLargeTablet ? 20.0 : 16.0,
                vertical: isLargeTablet ? 12.0 : 8.0,
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: TextStyle(
                fontSize: isLargeTablet ? 16.0 : 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    final context = Get.context!;
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return AppLocalizations.of(context)!.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return AppLocalizations.of(context)!.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return AppLocalizations.of(context)!.minutesAgo(difference.inMinutes);
    } else {
      return AppLocalizations.of(context)!.justNow;
    }
  }
}
