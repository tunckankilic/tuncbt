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

        final screenWidth = MediaQuery.of(context).size.width;
        final isLargeTablet = screenWidth >= 1200;
        final horizontalPadding = isLargeTablet ? screenWidth * 0.2 : 16.w;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isLargeTablet ? 32.0 : 16.w,
          ),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isLargeTablet ? 800.0 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(user, isLargeTablet),
                  SizedBox(height: isLargeTablet ? 40.0 : 24.h),
                  // Edit Button (sadece kendi profilinde görünsün)
                  if (userType == UserType.currentUser)
                    Padding(
                      padding: EdgeInsets.only(bottom: isLargeTablet ? 16.0 : 12.h),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditProfileModal(context, user, isLargeTablet),
                          icon: Icon(Icons.edit, size: isLargeTablet ? 20.0 : 18.sp),
                          label: Text(
                            'Profili Düzenle',
                            style: TextStyle(fontSize: isLargeTablet ? 18.0 : 14.sp),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isLargeTablet ? 24.0 : 16.w,
                              vertical: isLargeTablet ? 16.0 : 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  _buildInfoCard(
                    context: context,
                    isLargeTablet: isLargeTablet,
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
                  SizedBox(height: isLargeTablet ? 24.0 : 16.h),
                  _buildInfoCard(
                    context: context,
                    isLargeTablet: isLargeTablet,
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
                  Divider(height: isLargeTablet ? 48.0 : 32.0),
                  _buildDeleteAccountButton(context, isLargeTablet),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(UserModel user, bool isLargeTablet) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: isLargeTablet ? 75.0 : 50.r,
            backgroundImage: NetworkImage(
              user.imageUrl.isEmpty
                  ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'
                  : user.imageUrl,
            ),
          ),
          SizedBox(height: isLargeTablet ? 24.0 : 16.h),
          Text(
            user.name,
            style: TextStyle(
              fontSize: isLargeTablet ? 32.0 : 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isLargeTablet ? 12.0 : 8.h),
          Text(
            user.position,
            style: TextStyle(
              fontSize: isLargeTablet ? 20.0 : 16.sp,
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
    required BuildContext context,
    required bool isLargeTablet,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLargeTablet ? 20.0 : 15.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isLargeTablet ? 24.0 : 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: isLargeTablet ? 24.0 : 16.h),
            ...items.map((item) => _buildInfoItem(item, isLargeTablet)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(InfoItem item, bool isLargeTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLargeTablet ? 16.0 : 12.h),
      child: Row(
        children: [
          Icon(
            item.icon,
            color: AppTheme.primaryColor,
            size: isLargeTablet ? 32.0 : 24.sp,
          ),
          SizedBox(width: isLargeTablet ? 16.0 : 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: isLargeTablet ? 18.0 : 14.sp,
                  color: Colors.grey,
                ),
              ),
              Text(
                item.value,
                style: TextStyle(
                  fontSize: isLargeTablet ? 20.0 : 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context, bool isLargeTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeTablet ? 24.0 : 16.w,
        vertical: isLargeTablet ? 12.0 : 8.h,
      ),
      child: ElevatedButton(
        onPressed: () => _showDeleteAccountDialog(context, isLargeTablet),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isLargeTablet ? 20.0 : 12.h,
            horizontal: isLargeTablet ? 32.0 : 24.w,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_forever,
              size: isLargeTablet ? 32.0 : 24.sp,
            ),
            SizedBox(width: isLargeTablet ? 12.0 : 8.w),
            Text(
              AppLocalizations.of(context)!.deleteAccount,
              style: TextStyle(
                fontSize: isLargeTablet ? 20.0 : 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileModal(BuildContext context, UserModel user, bool isLargeTablet) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phoneNumber);
    final positionController = TextEditingController(text: user.position);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLargeTablet ? 24.0 : 20.r),
            topRight: Radius.circular(isLargeTablet ? 24.0 : 20.r),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isLargeTablet ? 32.0 : 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profili Düzenle',
                    style: TextStyle(
                      fontSize: isLargeTablet ? 28.0 : 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      size: isLargeTablet ? 32.0 : 24.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isLargeTablet ? 32.0 : 24.h),

              // Name Field
              Text(
                AppLocalizations.of(context)!.fullName,
                style: TextStyle(
                  fontSize: isLargeTablet ? 18.0 : 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: isLargeTablet ? 12.0 : 8.h),
              TextField(
                controller: nameController,
                style: TextStyle(fontSize: isLargeTablet ? 18.0 : 16.sp),
                decoration: InputDecoration(
                  hintText: 'Adınızı giriniz',
                  prefixIcon: Icon(Icons.person, size: isLargeTablet ? 28.0 : 24.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.r),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isLargeTablet ? 20.0 : 16.h,
                    horizontal: isLargeTablet ? 16.0 : 12.w,
                  ),
                ),
              ),
              SizedBox(height: isLargeTablet ? 24.0 : 20.h),

              // Phone Field
              Text(
                AppLocalizations.of(context)!.phoneNumber,
                style: TextStyle(
                  fontSize: isLargeTablet ? 18.0 : 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: isLargeTablet ? 12.0 : 8.h),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: isLargeTablet ? 18.0 : 16.sp),
                decoration: InputDecoration(
                  hintText: 'Telefon numaranızı giriniz',
                  prefixIcon: Icon(Icons.phone, size: isLargeTablet ? 28.0 : 24.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.r),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isLargeTablet ? 20.0 : 16.h,
                    horizontal: isLargeTablet ? 16.0 : 12.w,
                  ),
                ),
              ),
              SizedBox(height: isLargeTablet ? 24.0 : 20.h),

              // Position Field (Dropdown)
              Text(
                AppLocalizations.of(context)!.position,
                style: TextStyle(
                  fontSize: isLargeTablet ? 18.0 : 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: isLargeTablet ? 12.0 : 8.h),
              GestureDetector(
                onTap: () {
                  _showPositionPicker(context, positionController, isLargeTablet);
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: positionController,
                    style: TextStyle(fontSize: isLargeTablet ? 18.0 : 16.sp),
                    decoration: InputDecoration(
                      hintText: 'Pozisyonunuzu seçiniz',
                      prefixIcon: Icon(Icons.work, size: isLargeTablet ? 28.0 : 24.sp),
                      suffixIcon: Icon(Icons.arrow_drop_down, size: isLargeTablet ? 32.0 : 28.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.r),
                        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isLargeTablet ? 20.0 : 16.h,
                        horizontal: isLargeTablet ? 16.0 : 12.w,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: isLargeTablet ? 32.0 : 24.h),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      Get.snackbar('Hata', 'İsim boş olamaz');
                      return;
                    }
                    if (phoneController.text.trim().isEmpty) {
                      Get.snackbar('Hata', 'Telefon numarası boş olamaz');
                      return;
                    }
                    if (positionController.text.trim().isEmpty) {
                      Get.snackbar('Hata', 'Pozisyon boş olamaz');
                      return;
                    }

                    await controller.updateUserProfile(
                      name: nameController.text.trim(),
                      phoneNumber: phoneController.text.trim(),
                      position: positionController.text.trim(),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isLargeTablet ? 20.0 : 16.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.r),
                    ),
                  ),
                  child: Obx(() => controller.isLoading.value
                      ? SizedBox(
                          height: isLargeTablet ? 24.0 : 20.h,
                          width: isLargeTablet ? 24.0 : 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Güncelle',
                          style: TextStyle(
                            fontSize: isLargeTablet ? 20.0 : 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPositionPicker(
    BuildContext context,
    TextEditingController positionController,
    bool isLargeTablet,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLargeTablet ? 24.0 : 20.r),
            topRight: Radius.circular(isLargeTablet ? 24.0 : 20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.w),
              child: Text(
                AppLocalizations.of(context)!.chooseYourJob,
                style: TextStyle(
                  fontSize: isLargeTablet ? 24.0 : 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Constants.jobsList.length,
                itemBuilder: (context, index) {
                  final position = Constants.jobsList[index];
                  return ListTile(
                    leading: Container(
                      width: isLargeTablet ? 48.0 : 40.w,
                      height: isLargeTablet ? 48.0 : 40.w,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.r),
                      ),
                      child: Icon(
                        Icons.work,
                        color: AppTheme.primaryColor,
                        size: isLargeTablet ? 28.0 : 24.sp,
                      ),
                    ),
                    title: Text(
                      position,
                      style: TextStyle(
                        fontSize: isLargeTablet ? 18.0 : 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      positionController.text == position
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: positionController.text == position
                          ? AppTheme.primaryColor
                          : Colors.grey,
                      size: isLargeTablet ? 28.0 : 24.sp,
                    ),
                    onTap: () {
                      positionController.text = position;
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, bool isLargeTablet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.deleteAccount,
          style: TextStyle(
            color: Colors.red,
            fontSize: isLargeTablet ? 24.0 : 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: isLargeTablet ? 600.0 : null,
          child: Text(
            AppLocalizations.of(context)!.deleteAccountConfirm,
            style: TextStyle(
              fontSize: isLargeTablet ? 18.0 : 16.0,
            ),
          ),
        ),
        contentPadding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isLargeTablet ? 16.0 : 12.0,
                horizontal: isLargeTablet ? 24.0 : 16.0,
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: isLargeTablet ? 18.0 : 16.0,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final accountDeletionService = AccountDeletionService();
              await accountDeletionService.deleteAccount(LoginType.email);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isLargeTablet ? 16.0 : 12.0,
                horizontal: isLargeTablet ? 24.0 : 16.0,
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: TextStyle(
                color: Colors.red,
                fontSize: isLargeTablet ? 18.0 : 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
