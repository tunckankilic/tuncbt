import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/core/models/comment_model.dart';
import 'package:tuncbt/view/screens/screens.dart';
import 'package:timeago/timeago.dart' as timeago;
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

  const CommentWidget({
    Key? key,
    required this.commentId,
    required this.commenterId,
    required this.commenterName,
    required this.commentBody,
    required this.commenterImageUrl,
    required this.commenterTeamRole,
    required this.commentTime,
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
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: NetworkImage(
                    commenterImageUrl.isEmpty
                        ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'
                        : commenterImageUrl,
                  ),
                ),
                SizedBox(width: 12.w),
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
                                  fontSize: 14.sp,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              Text(
                                commenterTeamRole,
                                style: TextStyle(
                                  fontSize: 12.sp,
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
                                      Icon(Icons.edit, size: 18.sp),
                                      SizedBox(width: 8.w),
                                      Text('Düzenle'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete,
                                          size: 18.sp, color: Colors.red),
                                      SizedBox(width: 8.w),
                                      Text('Sil',
                                          style: TextStyle(color: Colors.red)),
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
                                decoration: InputDecoration(
                                  hintText: 'Yorumu düzenle...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        controller.cancelEditingComment(),
                                    child: Text('İptal'),
                                  ),
                                  SizedBox(width: 8.w),
                                  ElevatedButton(
                                    onPressed: () =>
                                        controller.updateComment(commentId),
                                    child: Text('Kaydet'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            commentBody,
                            style: TextStyle(
                              fontSize: 14.sp,
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
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _getTimeAgo(commentTime),
                style: TextStyle(
                  fontSize: 12.sp,
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
        title: Text('Yorumu Sil'),
        content: Text('Bu yorumu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteComment(commentId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Sil'),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}
