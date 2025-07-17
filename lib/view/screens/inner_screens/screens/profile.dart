import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/inner_screens/inner_screen_controller.dart';
import 'package:tuncbt/core/services/account_deletion.dart';
import 'package:tuncbt/view/widgets/drawer_widget.dart';
import 'package:tuncbt/core/services/team_controller.dart';
import 'package:tuncbt/core/models/user_model.dart';

enum UserType { commenter, worker, currentUser }

class InfoItem {
  final IconData icon;
  final String label;
  final String value;

  InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class ProfileScreen extends GetView<InnerScreenController> {
  static const routeName = "/profile";
  final String userId;
  final UserType userType;

  const ProfileScreen(
      {super.key, required this.userId, this.userType = UserType.currentUser});

  @override
  Widget build(BuildContext context) {
    final teamController = Get.find<TeamController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      drawer: DrawerWidget(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: TextStyle(color: Colors.red, fontSize: 16.sp),
            ),
          );
        }

        final user = controller.currentUser.value;
        if (user == UserModel.empty()) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.userNotFound,
              style: TextStyle(color: Colors.red, fontSize: 16.sp),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(user),
              SizedBox(height: 24.h),
              _buildInfoCard(
                title: AppLocalizations.of(context)!.personalInfo,
                items: [
                  InfoItem(
                    icon: Icons.person,
                    label: AppLocalizations.of(context)!.fullName,
                    value: user.name,
                  ),
                  InfoItem(
                    icon: Icons.email,
                    label: AppLocalizations.of(context)!.email,
                    value: user.email,
                  ),
                  InfoItem(
                    icon: Icons.phone,
                    label: AppLocalizations.of(context)!.phoneNumber,
                    value: user.phoneNumber,
                  ),
                  InfoItem(
                    icon: Icons.work,
                    label: AppLocalizations.of(context)!.position,
                    value: user.position,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildInfoCard(
                title: AppLocalizations.of(context)!.teamInfo,
                items: [
                  InfoItem(
                    icon: Icons.group,
                    label: AppLocalizations.of(context)!.teamName,
                    value: teamController.currentTeam?.teamName ??
                        AppLocalizations.of(context)!.teamNotFoundText,
                  ),
                  InfoItem(
                    icon: Icons.admin_panel_settings,
                    label: AppLocalizations.of(context)!.teamRole,
                    value: user.teamRole?.name.toUpperCase() ??
                        AppLocalizations.of(context)!.roleNotFoundText,
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildDeleteAccountButton(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundImage: NetworkImage(
              user.imageUrl.isEmpty
                  ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'
                  : user.imageUrl,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            user.position,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<InfoItem> items,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            ...items.map((item) => _buildInfoItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(InfoItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(item.icon, color: AppTheme.primaryColor, size: 24.sp),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
              Text(
                item.value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ElevatedButton(
        onPressed: () => _showDeleteAccountDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              AppLocalizations.of(context)!.deleteAccount,
              style: TextStyle(fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.deleteAccount,
          style: TextStyle(color: Colors.red),
        ),
        content: Text(AppLocalizations.of(context)!.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: AppTheme.textColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final accountDeletionService = AccountDeletionService();
              await accountDeletionService.deleteAccount(LoginType.email);
            },
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
