import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/constants/constants.dart';
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
    Get.off(() => ProfileScreen(userID: uid), binding: InnerScreenBindings());
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
              child: Image.network(
                'https://image.flaticon.com/icons/png/128/1252/1252006.png',
                height: 20,
                width: 20,
              ),
            ),
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
      child: ListView(
        children: [
          _buildDrawerHeader(),
          const SizedBox(height: 30),
          _buildListTile(
            label: 'All Tasks',
            icon: Icons.task_outlined,
            onTap: controller.navigateToAllTasks,
          ),
          _buildListTile(
            label: 'My account',
            icon: Icons.settings_outlined,
            onTap: controller.navigateToProfile,
          ),
          _buildListTile(
            label: 'Registered Workers',
            icon: Icons.workspaces_outline,
            onTap: controller.navigateToAllWorkers,
          ),
          _buildListTile(
            label: 'Add a task',
            icon: Icons.add_task,
            onTap: controller.navigateToAddTask,
          ),
          const Divider(thickness: 1),
          _buildListTile(
            label: 'Logout',
            icon: Icons.logout,
            onTap: controller.logout,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.cyan),
      child: Column(
        children: [
          Flexible(
            flex: 1,
            child: Image.network(
                'https://image.flaticon.com/icons/png/128/1055/1055672.png'),
          ),
          const SizedBox(height: 20),
          Text(
            'Work OS English',
            style: TextStyle(
              color: Constants.darkBlue,
              fontSize: 22,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Constants.darkBlue),
      title: Text(
        label,
        style: TextStyle(
          color: Constants.darkBlue,
          fontSize: 20,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
