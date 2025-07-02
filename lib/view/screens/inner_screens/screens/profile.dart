import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/auth/auth_bindings.dart';
import 'package:tuncbt/view/screens/auth/screens/login.dart';
import 'package:tuncbt/view/screens/inner_screens/inner_screen_controller.dart';
import 'package:tuncbt/view/screens/inner_screens/widgets/safe_profile_image.dart';
import 'package:tuncbt/core/services/account_deletion.dart';
import 'package:tuncbt/user_state.dart';
import 'package:tuncbt/view/widgets/drawer_widget.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/team_settings.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/invite_members.dart';
import 'package:provider/provider.dart';
import 'package:tuncbt/providers/team_provider.dart';
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
    final teamProvider = Provider.of<TeamProvider>(context);

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
        if (user == null) {
          return Center(
            child: Text(
              'Kullanıcı bilgileri bulunamadı',
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
                title: 'Kişisel Bilgiler',
                items: [
                  InfoItem(
                    icon: Icons.person,
                    label: 'Ad Soyad',
                    value: user.name,
                  ),
                  InfoItem(
                    icon: Icons.email,
                    label: 'E-posta',
                    value: user.email,
                  ),
                  InfoItem(
                    icon: Icons.phone,
                    label: 'Telefon',
                    value: user.phoneNumber,
                  ),
                  InfoItem(
                    icon: Icons.work,
                    label: 'Pozisyon',
                    value: user.position,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildInfoCard(
                title: 'Takım Bilgileri',
                items: [
                  InfoItem(
                    icon: Icons.group,
                    label: 'Takım',
                    value: teamProvider.currentTeam?.teamName ??
                        'Takım bulunamadı',
                  ),
                  InfoItem(
                    icon: Icons.admin_panel_settings,
                    label: 'Rol',
                    value:
                        user.teamRole?.name.toUpperCase() ?? 'Rol bulunamadı',
                  ),
                ],
              ),
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
}
