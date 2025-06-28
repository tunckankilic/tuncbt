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
      Get.to(() => UploadTask(), binding: InnerScreenBindings());
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
          title: Text(AppLocalizations.of(Get.context!)!.referralCode),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(Get.context!)!.inviteMembersHint),
              SelectableText(
                currentTeam.value!.referralCode ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(AppLocalizations.of(Get.context!)!.cancel),
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
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.person,
                  size: 20.r,
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(AppLocalizations.of(Get.context!)!.logout),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(Get.context!)!.logoutConfirm,
          style: const TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppLocalizations.of(Get.context!)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              await _auth.signOut();
              Get.offAll(() => const UserState());
            },
            child: Text(AppLocalizations.of(Get.context!)!.ok,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  DrawerWidget({Key? key}) : super(key: key);

  final DrawerController controller = Get.put(DrawerController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildDrawerHeader(context),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Column(
                      children: [
                        _buildAnimatedListTile(
                          context: context,
                          label: AppLocalizations.of(context)!.teamTasks,
                          icon: Icons.task_outlined,
                          onTap: controller.navigateToTeamTasks,
                        ),
                        _buildAnimatedListTile(
                          context: context,
                          label: AppLocalizations.of(context)!.myAccount,
                          icon: Icons.settings_outlined,
                          onTap: controller.navigateToProfile,
                        ),
                        _buildAnimatedListTile(
                          context: context,
                          label: AppLocalizations.of(context)!.teamMembers,
                          icon: Icons.groups_outlined,
                          onTap: controller.navigateToTeamMembers,
                        ),
                        if (controller.isAdmin.value ||
                            controller.currentUser.value?.teamRole?.name ==
                                'manager')
                          _buildAnimatedListTile(
                            context: context,
                            label: AppLocalizations.of(context)!.newTask,
                            icon: Icons.add_task,
                            onTap: controller.navigateToAddTask,
                          ),
                        _buildAnimatedListTile(
                          context: context,
                          label:
                              AppLocalizations.of(context)!.shareReferralCode,
                          icon: Icons.share,
                          onTap: controller.shareReferralCode,
                        ),
                        if (controller.isAdmin.value)
                          _buildAnimatedListTile(
                            context: context,
                            label: AppLocalizations.of(context)!.teamSettings,
                            icon: Icons.settings,
                            onTap: controller.navigateToTeamSettings,
                          ),
                        Divider(
                            color: Colors.white.withOpacity(0.5),
                            thickness: 1,
                            height: 40.h),
                        _buildAnimatedListTile(
                          context: context,
                          label: AppLocalizations.of(context)!.logout,
                          icon: Icons.logout,
                          onTap: controller.logout,
                          isLogout: true,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          height: 170.h,
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return Container(
        height: 170.h,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.r),
            bottomRight: Radius.circular(30.r),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 70.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              child: ClipOval(
                  child: Icon(
                Icons.person,
                size: 30.r,
              )),
            ),
            SizedBox(height: 10.h),
            Text(
              controller.currentTeam.value?.teamName ??
                  AppLocalizations.of(context)!.appTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (controller.currentUser.value != null)
              Text(
                controller.currentUser.value!.teamRole?.name.toUpperCase() ??
                    '',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildAnimatedListTile({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(-100 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon,
            color: isLogout ? Colors.red : Colors.white, size: 24.sp),
        title: Text(
          label,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
