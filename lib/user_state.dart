import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/services/auth_service.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/auth/auth_bindings.dart';
import 'package:tuncbt/view/screens/auth/auth_controller.dart';
import 'package:tuncbt/view/screens/auth/auth/login.dart';
import 'package:tuncbt/view/screens/auth/auth/referral_input.dart';
import 'package:tuncbt/view/screens/tasks_screen/screens/tasks_screen.dart';
import 'package:tuncbt/view/screens/tasks_screen/tasks_screen_bindings.dart';

class UserState extends StatelessWidget {
  const UserState({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();
    final l10n = AppLocalizations.of(context)!;

    // Initialize AuthController if not already initialized
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController());
    }

    return Obx(() {
      // Loading state
      if (authService.isUnknown || authService.isLoading.value) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.loading),
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
      return Scaffold(
        body: Center(
          child: Text(l10n.error),
        ),
      );
    });
  }
}
