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
import 'package:provider/provider.dart';
import 'package:tuncbt/providers/team_provider.dart';
import 'package:tuncbt/view/screens/chat/chat_index.dart';

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
  const DrawerWidget({Key? key}) : super(key: key);

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      // Önce drawer'ı kapat
      Navigator.of(context).pop();

      // TeamProvider'ı temizle
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);
      await teamProvider.clearTeamData();

      // Firebase'den çıkış yap
      await FirebaseAuth.instance.signOut();

      // Auth sayfasına yönlendir
      Get.offAllNamed('/auth');
    } catch (e) {
      print('Sign out error: $e');
      Get.snackbar(
        'Hata',
        'Çıkış yapılırken bir sorun oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final currentTeam = teamProvider.currentTeam;
    final isAdmin = teamProvider.isAdmin;

    return Drawer(
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
                    leading: Icon(Icons.task, color: AppTheme.primaryColor),
                    title: Text(AppLocalizations.of(context)!.tasks),
                    onTap: () {
                      Get.back();
                      Get.toNamed(TasksScreen.routeName);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.message, color: AppTheme.primaryColor),
                    title: const Text('Mesajlar'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
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
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
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
                  if (isAdmin) ...[
                    ListTile(
                      leading: Icon(Icons.people, color: AppTheme.primaryColor),
                      title: Text(AppLocalizations.of(context)!.allWorkers),
                      onTap: () {
                        Get.back();
                        Get.toNamed(AllWorkersScreen.routeName);
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.settings, color: AppTheme.primaryColor),
                      title: const Text('Takım Ayarları'),
                      onTap: () {
                        Get.back();
                        Get.toNamed('/team-settings');
                      },
                    ),
                  ],
                  ListTile(
                    leading: Icon(Icons.person, color: AppTheme.primaryColor),
                    title: Text(AppLocalizations.of(context)!.profile),
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
                  ),
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  label: Text(
                    'Çıkış Yap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
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
