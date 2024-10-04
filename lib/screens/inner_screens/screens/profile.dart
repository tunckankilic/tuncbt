import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuncbt/config/constants.dart';
import 'package:tuncbt/screens/auth/auth_bindings.dart';
import 'package:tuncbt/screens/auth/screens/login.dart';
import 'package:tuncbt/screens/inner_screens/inner_screen_controller.dart';
import 'package:tuncbt/screens/inner_screens/widgets/safe_profile_image.dart';
import 'package:tuncbt/services/account_deletion.dart';
import 'package:tuncbt/user_state.dart';
import 'package:tuncbt/widgets/drawer_widget.dart';

enum UserType { commenter, worker, currentUser }

class ProfileScreen extends GetView<InnerScreenController> {
  static const routeName = "/profile";
  final String userId;
  final UserType userType;

  ProfileScreen(
      {Key? key, required this.userId, this.userType = UserType.currentUser})
      : super(key: key);

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
              imageUrl: controller.currentUser.value.userImage,
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
          _buildQuickActions(),
          SizedBox(height: 20.h),
          _buildJobInfo(),
          SizedBox(height: 20.h),
          _buildContactInfo(),
          SizedBox(height: 20.h),
          if (userType == UserType.currentUser)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLogoutButton(),
                SizedBox(
                  height: 5.h,
                ),
                _buildDeleteAccountButton(context),
              ],
            ),
          if (userType == UserType.worker)
            _buildWorkerActions()
          else if (userType == UserType.commenter)
            _buildCommenterActions(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _quickActionButton(Icons.task, 'Tasks', () {}),
            _quickActionButton(Icons.message, 'Messages', () {}),
            _quickActionButton(Icons.notifications, 'Notifications', () {}),
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30.sp),
          onPressed: onPressed,
          color: Theme.of(Get.context!).colorScheme.primary,
        ),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildJobInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Information',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(Get.context!).colorScheme.primary,
              ),
            ),
            SizedBox(height: 10.h),
            _infoRow(
                Icons.work, controller.currentUser.value.positionInCompany),
            _infoRow(Icons.calendar_today,
                'Joined ${controller.currentUser.value.createdAt.toString().split(' ')[0]}'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(Get.context!).colorScheme.primary,
              ),
            ),
            SizedBox(height: 10.h),
            _infoRow(Icons.email, controller.currentUser.value.email),
            _infoRow(Icons.phone, controller.currentUser.value.phoneNumber),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon,
              color: Theme.of(Get.context!).colorScheme.secondary, size: 24.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(Get.context!).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(Get.context!).colorScheme.primary,
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

  Widget _buildCommenterActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comment Actions',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(Get.context!).colorScheme.primary,
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
                backgroundColor: Theme.of(Get.context!).colorScheme.primary,
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

  Widget _buildLogoutButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          controller.signOut();
          Get.offAll(() => const UserState(), binding: AuthBindings());
        },
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          'Logout',
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
          'Delete Account',
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
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
}
