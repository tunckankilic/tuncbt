import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/config/constants.dart';
import 'package:tuncbt/screens/inner_screens/inner_screen_controller.dart';
import 'package:tuncbt/screens/screens.dart';

class CommentWidget extends StatelessWidget {
  final String commentId;
  final String commenterId;
  final String commenterName;
  final String commentBody;
  final String commenterImageUrl;

  const CommentWidget({
    Key? key,
    required this.commentId,
    required this.commenterId,
    required this.commenterName,
    required this.commentBody,
    required this.commenterImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: OpenContainer(
        transitionDuration: Duration(milliseconds: 500),
        openBuilder: (context, _) => GetBuilder<InnerScreenController>(
          init: InnerScreenController(),
          builder: (controller) => ProfileScreen(),
        ),
        closedElevation: 0,
        closedColor: Colors.transparent,
        closedBuilder: (context, openContainer) => InkWell(
          onTap: () {
            Get.toNamed(ProfileScreen.routeName,
                arguments: {'userId': commenterId});
          },
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
    return Hero(
      tag: 'avatar_$commenterId',
      child: Container(
        height: 40.w,
        width: 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 2.w,
            color: Theme.of(context).colorScheme.secondary,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 3),
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
    );
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
        Text(
          commenterName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: Theme.of(context).primaryColor,
          ),
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
              '2 saat önce', // Bu kısmı gerçek zamana göre güncelleyebilirsiniz
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
