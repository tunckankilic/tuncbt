import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:tuncbt/view/widgets/language_switcher.dart';

enum UserType { commenter, worker, currentUser }

class ProfileScreen extends GetView<InnerScreenController> {
  static const routeName = "/profile";
  final String userId;
  final UserType userType;

  const ProfileScreen(
      {super.key, required this.userId, this.userType = UserType.currentUser});

  @override
  Widget build(BuildContext context) {
    controller.loadUserData(userId);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: userType == UserType.currentUser ? DrawerWidget() : null,
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context),
                  SliverToBoxAdapter(
                    child: _buildProfileContent(context),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250.h,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            SafeProfileImage(
              imageUrl: controller.currentUser.value.imageUrl,
              size: MediaQuery.of(context).size.width,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                controller.currentUser.value.name.isEmpty
                    ? 'No Name'
                    : controller.currentUser.value.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (userType == UserType.currentUser &&
                controller.currentUser.value.name.isEmpty)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _showEditNameDialog(context),
              ),
          ],
        ),
        titlePadding: EdgeInsets.only(left: 16.w, bottom: 16.h, right: 16.w),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickActions(context),
          SizedBox(height: 20.h),
          _buildJobInfo(context),
          SizedBox(height: 20.h),
          _buildContactInfo(context),
          SizedBox(height: 20.h),
          _buildTeamInfo(context),
          SizedBox(height: 20.h),
          if (userType == UserType.currentUser)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LanguageSwitcher(),
                SizedBox(height: 20.h),
                _buildLogoutButton(context),
                SizedBox(height: 5.h),
                _buildDeleteAccountButton(context),
              ],
            ),
          if (userType == UserType.worker)
            _buildWorkerActions(context)
          else if (userType == UserType.commenter)
            _buildCommenterActions(context),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.quickActions,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickActionButton(context, Icons.task,
                    AppLocalizations.of(context)!.tasks, () {}),
                _quickActionButton(context, Icons.message,
                    AppLocalizations.of(context)!.messages, () {}),
                _quickActionButton(context, Icons.notifications,
                    AppLocalizations.of(context)!.notifications, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton(BuildContext context, IconData icon, String label,
      VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30.sp),
          onPressed: onPressed,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildJobInfo(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.jobInformation,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 10.h),
            _infoRow(
                context, Icons.work, controller.currentUser.value.position),
            _infoRow(
              context,
              Icons.calendar_today,
              AppLocalizations.of(context)!.joinedDate(
                controller.currentUser.value.createdAt.toString().split(' ')[0],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.contactInformation,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 10.h),
            _infoRow(context, Icons.email, controller.currentUser.value.email),
            _infoRow(
                context, Icons.phone, controller.currentUser.value.phoneNumber),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon,
              color: Theme.of(context).colorScheme.secondary, size: 24.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerActions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.contact,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _contactButton(
                  color: Colors.green,
                  icon: FontAwesomeIcons.whatsapp,
                  onPressed: controller.openWhatsAppChat,
                ),
                _contactButton(
                  color: Colors.red,
                  icon: Icons.mail_outline,
                  onPressed: controller.mailTo,
                ),
                _contactButton(
                  color: Colors.purple,
                  icon: Icons.call_outlined,
                  onPressed: controller.callPhoneNumber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactButton({
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        padding: EdgeInsets.all(16.w),
      ),
      child: Icon(icon, color: Colors.white, size: 24.sp),
    );
  }

  Widget _buildCommenterActions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.commentActions,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () {
                // Implement reply to comment action
              },
              icon: const Icon(Icons.reply, color: Colors.white),
              label: const Text('Reply to Comment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r)),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          controller.signOut();
          Get.offAll(() => const UserState(), binding: AuthBindings());
        },
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.logout,
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _showDeleteAccountDialog(context),
        icon: const Icon(Icons.delete_forever, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.deleteAccount,
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteAccount),
          content: Text(AppLocalizations.of(context)!.deleteAccountConfirm),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.delete,
                  style: const TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _processAccountDeletion();
              },
            ),
          ],
        );
      },
    );
  }

  void _processAccountDeletion() async {
    try {
      var deletion = Get.put(AccountDeletionService());
      LoginType loginType = _determineLoginType(); // Define login type
      await deletion.deleteAccount(loginType);
      // When account has deleted, route to login
      Get.offAll(() => Login());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete account. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  LoginType _determineLoginType() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    // Check Profider
    for (UserInfo userInfo in user.providerData) {
      switch (userInfo.providerId) {
        case 'apple.com':
          return LoginType.apple;
        case 'google.com':
          return LoginType.google;
        case 'password':
          return LoginType.email;
      }
    }

    // Default email
    return LoginType.email;
  }

  void _showEditNameDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Enter your name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  controller.updateUserName(nameController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeamInfo(BuildContext context) {
    return Obx(() {
      final hasTeam = controller.currentTeam.value != null;
      final isAdmin = controller.isTeamAdmin.value;

      return Card(
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.teamInformation,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (hasTeam && isAdmin)
                    IconButton(
                      icon: Icon(Icons.settings, size: 24.sp),
                      onPressed: () {
                        Get.to(() => const TeamSettingsScreen());
                      },
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              SizedBox(height: 10.h),
              if (!hasTeam)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.group_off,
                        size: 48.sp,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppLocalizations.of(context)!.notInTeam,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _infoRow(context, Icons.group,
                    controller.currentTeam.value!.teamName),
                _infoRow(context, Icons.person_outline,
                    controller.currentTeamMember.value!.role.name),
                _infoRow(context, Icons.people,
                    AppLocalizations.of(context)!.teamMembers),
                _infoRow(
                    context,
                    Icons.calendar_today,
                    AppLocalizations.of(context)!.teamJoinDate(controller
                        .currentTeamMember.value!.joinedAt
                        .toString()
                        .split(' ')[0])),
                if (isAdmin) ...[
                  Divider(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.referralCode,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Text(
                                  controller.currentTeam.value!.referralCode ??
                                      '',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy, size: 20.sp),
                                  onPressed: controller.copyReferralCode,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => const InviteMembersScreen());
                        },
                        icon: Icon(Icons.person_add, size: 20.sp),
                        label: Text(AppLocalizations.of(context)!.addMember),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (userType == UserType.currentUser && !isAdmin) ...[
                  Divider(height: 20.h),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _showLeaveTeamDialog(context),
                      icon: Icon(Icons.exit_to_app, size: 20.sp),
                      label: Text(AppLocalizations.of(context)!.leaveTeam),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      );
    });
  }

  void _showLeaveTeamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.leaveTeam),
          content: Text(
            AppLocalizations.of(context)!.leaveTeamConfirm,
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.leave,
                  style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                controller.leaveTeam();
              },
            ),
          ],
        );
      },
    );
  }
}
