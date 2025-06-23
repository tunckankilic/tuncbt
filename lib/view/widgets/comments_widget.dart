import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/view/screens/screens.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        openBuilder: (context, _) => ProfileScreen(
          userId: commenterId,
          userType: UserType.commenter,
        ),
        closedElevation: 0,
        closedColor: Colors.transparent,
        closedBuilder: (context, openContainer) => InkWell(
          onTap: openContainer,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCommenterAvatar(context),
              SizedBox(width: 12.w),
              Expanded(child: _buildCommentContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommenterAvatar(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'avatar_$commenterId',
          child: Container(
            height: 40.w,
            width: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2.w,
                color: _getRoleColor(),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: commenterImageUrl.isNotEmpty
                  ? Image.network(
                      commenterImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _defaultAvatar(context),
                    )
                  : _defaultAvatar(context),
            ),
          ),
        ),
        if (commenterTeamRole.isNotEmpty)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: _getRoleColor(),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5.w,
                ),
              ),
              child: Icon(
                _getRoleIcon(),
                size: 10.sp,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Color _getRoleColor() {
    switch (commenterTeamRole.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'member':
        return Colors.blue;
      default:
        return Theme.of(Get.context!).colorScheme.secondary;
    }
  }

  IconData _getRoleIcon() {
    switch (commenterTeamRole.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'manager':
        return Icons.manage_accounts;
      case 'member':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  Widget _defaultAvatar(BuildContext context) {
    return Icon(
      Icons.person,
      size: 24.sp,
      color: Theme.of(context).primaryColor,
    );
  }

  Widget _buildCommentContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              commenterName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
            if (commenterTeamRole.isNotEmpty) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _getRoleColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  commenterTeamRole.capitalize!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _getRoleColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            commentBody,
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 14.sp,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(Icons.access_time,
                size: 12.sp, color: AppTheme.lightTextColor),
            SizedBox(width: 4.w),
            Text(
              timeago.format(commentTime, locale: 'tr'),
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.lightTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
