import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/view/screens/chat/chat_screen.dart';
import 'package:tuncbt/view/screens/inner_screens/inner_screen_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/profile.dart';

class AllWorkersWidget extends StatelessWidget {
  final String userID;
  final String userName;
  final String userEmail;
  final String positionInCompany;
  final String phoneNumber;
  final String userImageUrl;

  const AllWorkersWidget({
    Key? key,
    required this.userID,
    required this.userName,
    required this.userEmail,
    required this.positionInCompany,
    required this.phoneNumber,
    required this.userImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      child: OpenContainer(
        transitionDuration: Duration(milliseconds: 500),
        openBuilder: (context, _) {
          final controller = Get.put(InnerScreenController());
          controller.loadUserData(userID);

          return ProfileScreen(
            userId: userID,
            userType: UserType.worker,
          );
        },
        closedElevation: 5,
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        closedColor: Theme.of(context).cardColor,
        closedBuilder: (context, openContainer) => InkWell(
          onTap: openContainer,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Row(
              children: [
                _buildLeadingAvatar(),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(),
                      SizedBox(height: 5.h),
                      _buildSubtitle(),
                    ],
                  ),
                ),
                _buildTrailingButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingAvatar() {
    return Hero(
      tag: 'avatar_$userID',
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2.w,
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
          borderRadius: BorderRadius.circular(25.r),
          child: Image.network(
            userImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.person,
              size: 30.sp,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      userName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          positionInCompany,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.secondaryColor,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          phoneNumber,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.lightTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.mail_outline,
            size: 24.sp,
            color: AppTheme.accentColor,
          ),
          onPressed: () => _mailTo(context),
        ),
        IconButton(
          icon: Icon(
            Icons.chat_bubble_outline,
            size: 24.sp,
            color: AppTheme.accentColor,
          ),
          onPressed: () => _openChat(context),
        ),
      ],
    );
  }

// Add this new method to handle chat navigation
  void _openChat(BuildContext context) {
    // Create a UserModel instance from the current worker's data
    final user = UserModel(
        id: userID,
        name: userName,
        email: userEmail,
        imageUrl: userImageUrl,
        phoneNumber: phoneNumber,
        position: positionInCompany,
        createdAt: DateTime.now());

    // Navigate to chat screen using Get
    Get.toNamed(
      ChatScreen.routeName,
      arguments: user,
    );
  }

  void _mailTo(BuildContext context) async {
    final mailUrl = 'mailto:$userEmail';
    if (await canLaunchUrl(Uri.parse(mailUrl))) {
      await launchUrl(Uri.parse(mailUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('E-posta uygulaması açılamadı'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
