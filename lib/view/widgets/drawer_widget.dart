import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/core/services/team_service.dart';
import 'package:tuncbt/core/models/team.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/bindings.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/profile.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/team_settings.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/upload_task.dart';
import 'package:tuncbt/view/screens/all_workers/all_workers.dart';
import 'package:tuncbt/view/screens/tasks_screen/screens/tasks_screen.dart';
import 'package:tuncbt/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:tuncbt/core/services/team_controller.dart';
import 'package:tuncbt/view/screens/chat/chat_index.dart';
import 'package:tuncbt/core/services/logout_service.dart';

class DrawerController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TeamService _teamService = TeamService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<Team?> currentTeam = Rx<Team?>(null);
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAdmin = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserAndTeamData();
  }

  Future<void> loadUserAndTeamData() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        // Kullanıcı verilerini yükle
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          currentUser.value = UserModel.fromFirestore(userDoc);

          // Takım verilerini yükle
          if (currentUser.value?.teamId != null) {
            final result =
                await _teamService.getTeamInfo(currentUser.value!.teamId!);
            if (result.success) {
              currentTeam.value = result.data;
              isAdmin.value =
                  currentUser.value?.teamRole?.name.toLowerCase() == 'admin';
            }
          }
        }
      }
    } catch (e) {
      log('Error loading user and team data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToTeamTasks() {
    if (currentTeam.value != null) {
      Get.off(() => TasksScreen(), binding: InnerScreenBindings());
    }
  }

  void navigateToProfile() {
    final String uid = _auth.currentUser!.uid;
    Get.off(() => ProfileScreen(userId: uid), binding: InnerScreenBindings());
  }

  void navigateToTeamMembers() {
    if (currentTeam.value != null) {
      Get.off(() => AllWorkersScreen(), binding: AllWorkersBindings());
    }
  }

  void navigateToAddTask() {
    if (currentTeam.value != null) {
      Get.to(() => UploadTaskScreen(), binding: InnerScreenBindings());
    }
  }

  void navigateToTeamSettings() {
    if (currentTeam.value != null && isAdmin.value) {
      Get.to(() => const TeamSettingsScreen(), binding: InnerScreenBindings());
    }
  }

  void shareReferralCode() {
    if (currentTeam.value != null) {
      Get.dialog(
        AlertDialog(
          title: Text(
            AppLocalizations.of(Get.context!)!.referralCode,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(Get.context!)!.inviteMembersHint,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textColor,
                ),
              ),
              SizedBox(height: 16.h),
              SelectableText(
                currentTeam.value!.referralCode ?? '',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 16.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
              ),
              child: Text(
                AppLocalizations.of(Get.context!)!.cancel,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> logout() async {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.person,
                size: 24.sp,
                color: AppTheme.primaryColor,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                AppLocalizations.of(Get.context!)!.logout,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(Get.context!)!.logoutConfirm,
          style: TextStyle(
            fontSize: 16.sp,
            fontStyle: FontStyle.italic,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 16.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
            ),
            child: Text(
              AppLocalizations.of(Get.context!)!.cancel,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _auth.signOut();
              Get.offAll(() => const UserState());
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
            ),
            child: Text(
              AppLocalizations.of(Get.context!)!.ok,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  final bool isLargeTablet;

  const DrawerWidget({
    Key? key,
    this.isLargeTablet = false,
  }) : super(key: key);

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      Navigator.of(context).pop(); // Drawer'ı kapat

      final logoutService = Get.find<LogoutService>();
      await logoutService.logout();
    } catch (e) {
      print('Sign out error: $e');
      Get.snackbar(
        AppLocalizations.of(context)!.error,
        AppLocalizations.of(context)!.logoutError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamController = Get.find<TeamController>();
    final currentTeam = teamController.currentTeam;
    final isAdmin = teamController.isAdmin;

    return Drawer(
      width: 300.w,
      child: Container(
        color: AppTheme.backgroundColor,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentTeam?.teamName ??
                        AppLocalizations.of(context)!.teamTasks,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.task,
                      color: AppTheme.primaryColor,
                      size: 24.sp,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.tasks,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    onTap: () {
                      Get.back();
                      Get.toNamed(TasksScreen.routeName);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.message,
                      color: AppTheme.primaryColor,
                      size: 24.sp,
                    ),
                    title: Text(
                      'Mesajlar',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .collection('chats')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            int unreadCount = 0;
                            for (var doc in snapshot.data!.docs) {
                              unreadCount += (doc.data() as Map<String,
                                      dynamic>)['unreadCount'] as int? ??
                                  0;
                            }
                            return unreadCount > 0
                                ? Text(
                                    unreadCount.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    onTap: () {
                      Get.back();
                      Get.toNamed(ChatIndexScreen.routeName);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.people,
                      color: AppTheme.primaryColor,
                      size: 24.sp,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.allWorkers,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    onTap: () {
                      Get.back();
                      Get.toNamed(AllWorkersScreen.routeName);
                    },
                  ),
                  if (isAdmin) ...[
                    ListTile(
                      leading: Icon(
                        Icons.settings,
                        color: AppTheme.primaryColor,
                        size: 24.sp,
                      ),
                      title: Text(
                        'Takım Ayarları',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      onTap: () {
                        Get.back();
                        Get.toNamed('/team-settings');
                      },
                    ),
                  ],
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: AppTheme.primaryColor,
                      size: 24.sp,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.profile,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    onTap: () {
                      Get.back();
                      Get.toNamed('/profile');
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: ElevatedButton.icon(
                  onPressed: () => _handleSignOut(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(double.infinity, 50.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  label: Text(
                    'Çıkış Yap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
