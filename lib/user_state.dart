import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/services/auth_service.dart';
import 'package:tuncbt/view/screens/auth/auth_bindings.dart';
import 'package:tuncbt/view/screens/auth/screens/login.dart';
import 'package:tuncbt/view/screens/auth/screens/referral_input.dart';
import 'package:tuncbt/view/screens/tasks_screen/screens/tasks_screen.dart';
import 'package:tuncbt/view/screens/tasks_screen/tasks_screen_bindings.dart';

class UserState extends StatelessWidget {
  const UserState({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();

    return Obx(() {
      // Loading state
      if (authService.isUnknown || authService.isLoading.value) {
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Yükleniyor...'),
              ],
            ),
          ),
        );
      }

      // Unauthenticated state
      if (authService.isUnauthenticated) {
        // Ensure bindings are set
        if (!Get.isRegistered<AuthBindings>()) {
          Get.put(AuthBindings());
        }
        return Login();
      }

      // Authenticated but needs team
      if (authService.needsTeam) {
        if (!Get.isRegistered<AuthBindings>()) {
          Get.put(AuthBindings());
        }
        return ReferralInputScreen();
      }

      // Fully authenticated with team
      if (authService.isAuthenticated) {
        if (!Get.isRegistered<TasksScreenBindings>()) {
          Get.put(TasksScreenBindings());
        }
        return TasksScreen();
      }

      // Fallback - should not reach here
      return const Scaffold(
        body: Center(
          child: Text('Beklenmeyen durum'),
        ),
      );
    });
  }
}
