import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/config/constants.dart';
import 'package:tuncbt/screens/bindings.dart';
import 'package:tuncbt/screens/inner_screens/screens/profile.dart';
import 'package:tuncbt/screens/inner_screens/screens/upload_task.dart';
import 'package:tuncbt/screens/all_workers/screens/all_workers.dart';
import 'package:tuncbt/screens/tasks_screen/screens/tasks_screen.dart';
import 'package:tuncbt/user_state.dart';

class DrawerController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void navigateToAllTasks() {
    Get.off(() => TasksScreen(), binding: InnerScreenBindings());
  }

  void navigateToProfile() {
    final String uid = _auth.currentUser!.uid;
    Get.off(() => ProfileScreen(), binding: InnerScreenBindings());
  }

  void navigateToAllWorkers() {
    Get.off(() => AllWorkersScreen(), binding: AllWorkersBindings());
  }

  void navigateToAddTask() {
    Get.to(() => const UploadTask(), binding: InnerScreenBindings());
  }

  void logout() {
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
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Sign out'),
            ),
          ],
        ),
        content: const Text(
          'Do you want to Sign out?',
          style: TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _auth.signOut();
              Get.offAll(() => const UserState());
            },
            child: const Text('OK', style: TextStyle(color: Colors.red)),
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
              _buildDrawerHeader(),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAnimatedListTile(
                        label: 'All Tasks',
                        icon: Icons.task_outlined,
                        onTap: controller.navigateToAllTasks,
                      ),
                      _buildAnimatedListTile(
                        label: 'My account',
                        icon: Icons.settings_outlined,
                        onTap: controller.navigateToProfile,
                      ),
                      _buildAnimatedListTile(
                        label: 'Registered Workers',
                        icon: Icons.workspaces_outline,
                        onTap: controller.navigateToAllWorkers,
                      ),
                      _buildAnimatedListTile(
                        label: 'Add a task',
                        icon: Icons.add_task,
                        onTap: controller.navigateToAddTask,
                      ),
                      Divider(
                          color: Colors.white.withOpacity(0.5),
                          thickness: 1,
                          height: 40.h),
                      _buildAnimatedListTile(
                        label: 'Logout',
                        icon: Icons.logout,
                        onTap: controller.logout,
                        isLogout: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
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
            'TuncBT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedListTile({
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
