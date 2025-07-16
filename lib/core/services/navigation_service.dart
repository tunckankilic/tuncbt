import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/view/screens/screens.dart';
import 'package:tuncbt/core/models/user_model.dart';

enum NavigationDestination {
  tasks,
  taskDetails,
  profile,
  teamMembers,
  teamSettings,
  inviteMembers,
  uploadTask,
  chat,
  chatIndex,
  auth,
  login,
  register,
  referral,
  passwordReset,
}

class NavigationService extends GetxService {
  // Route name constants - centralized
  static const String tasksRoute = "/tasks";
  static const String taskDetailsRoute = "/task-details";
  static const String profileRoute = "/profile";
  static const String teamMembersRoute = "/team-members";
  static const String teamSettingsRoute = "/team-settings";
  static const String inviteMembersRoute = "/invite-members";
  static const String uploadTaskRoute = "/upload-task";
  static const String chatRoute = "/chat";
  static const String chatIndexRoute = "/chat-index";
  static const String authRoute = "/auth";
  static const String loginRoute = "/login";
  static const String registerRoute = "/register";
  static const String referralRoute = "/auth/referral";
  static const String passwordResetRoute = "/auth/password-reset";

  // Navigation with proper error handling
  Future<T?> navigateTo<T>(
    NavigationDestination destination, {
    Map<String, dynamic>? arguments,
    bool clearStack = false,
    bool replace = false,
  }) async {
    try {
      final route = _getRouteForDestination(destination);

      if (clearStack) {
        return await Get.offAllNamed<T>(route, arguments: arguments);
      } else if (replace) {
        return await Get.offNamed<T>(route, arguments: arguments);
      } else {
        return await Get.toNamed<T>(route, arguments: arguments);
      }
    } catch (e) {
      print('NavigationService: Navigation error: $e');
      _handleNavigationError(e);
      return null;
    }
  }

  // Navigate to specific destinations with typed parameters
  Future<void> navigateToTasks({bool clearStack = false}) async {
    await navigateTo(NavigationDestination.tasks, clearStack: clearStack);
  }

  Future<void> navigateToTaskDetails({
    required String taskId,
    required String uploadedBy,
    String? teamId,
    String? scrollToComment,
  }) async {
    await navigateTo(
      NavigationDestination.taskDetails,
      arguments: {
        'taskID': taskId,
        'uploadedBy': uploadedBy,
        if (teamId != null) 'teamId': teamId,
        if (scrollToComment != null) 'scrollToComment': scrollToComment,
      },
    );
  }

  Future<void> navigateToProfile({
    required String userId,
    UserType userType = UserType.currentUser,
  }) async {
    await navigateTo(
      NavigationDestination.profile,
      arguments: {
        'userId': userId,
        'userType': userType,
      },
    );
  }

  Future<void> navigateToChat({required UserModel receiver}) async {
    await navigateTo(
      NavigationDestination.chat,
      arguments: {'receiver': receiver},
    );
  }

  Future<void> navigateToAuth({bool clearStack = true}) async {
    await navigateTo(NavigationDestination.auth, clearStack: clearStack);
  }

  Future<void> navigateToLogin({bool clearStack = false}) async {
    await navigateTo(NavigationDestination.login, clearStack: clearStack);
  }

  Future<void> navigateToRegister({bool clearStack = false}) async {
    await navigateTo(NavigationDestination.register, clearStack: clearStack);
  }

  Future<void> navigateToReferral({bool clearStack = false}) async {
    await navigateTo(NavigationDestination.referral, clearStack: clearStack);
  }

  // Handle notification navigation
  Future<void> handleNotificationNavigation(Map<String, dynamic> data) async {
    try {
      final type = data['type'] as String?;
      final taskId = data['taskId'] as String?;
      final uploadedBy = data['uploadedBy'] as String?;

      print(
          'NavigationService: Handling notification - Type: $type, TaskID: $taskId');

      if (taskId == null || uploadedBy == null) {
        print('NavigationService: Invalid notification data');
        return;
      }

      switch (type) {
        case 'new_task':
        case 'status_update':
        case 'new_comment':
          await navigateToTaskDetails(
            taskId: taskId,
            uploadedBy: uploadedBy,
            teamId: data['teamId'],
            scrollToComment: data['commentId'],
          );
          break;
        default:
          print('NavigationService: Unknown notification type: $type');
          // Default to tasks screen
          await navigateToTasks();
      }
    } catch (e) {
      print('NavigationService: Error handling notification navigation: $e');
      // Fallback to tasks screen
      await navigateToTasks();
    }
  }

  // Back navigation with safety checks
  void goBack() {
    if (Get.routing.previous.isNotEmpty) {
      Get.back();
    } else {
      // If no previous route, go to tasks
      navigateToTasks(clearStack: true);
    }
  }

  // Check if we can go back
  bool canGoBack() {
    return Get.routing.previous.isNotEmpty;
  }

  // Get current route name
  String? getCurrentRoute() {
    return Get.currentRoute;
  }

  // Private helper methods
  String _getRouteForDestination(NavigationDestination destination) {
    switch (destination) {
      case NavigationDestination.tasks:
        return tasksRoute;
      case NavigationDestination.taskDetails:
        return taskDetailsRoute;
      case NavigationDestination.profile:
        return profileRoute;
      case NavigationDestination.teamMembers:
        return teamMembersRoute;
      case NavigationDestination.teamSettings:
        return teamSettingsRoute;
      case NavigationDestination.inviteMembers:
        return inviteMembersRoute;
      case NavigationDestination.uploadTask:
        return uploadTaskRoute;
      case NavigationDestination.chat:
        return chatRoute;
      case NavigationDestination.chatIndex:
        return chatIndexRoute;
      case NavigationDestination.auth:
        return authRoute;
      case NavigationDestination.login:
        return loginRoute;
      case NavigationDestination.register:
        return registerRoute;
      case NavigationDestination.referral:
        return referralRoute;
      case NavigationDestination.passwordReset:
        return passwordResetRoute;
    }
  }

  void _handleNavigationError(dynamic error) {
    print('NavigationService: Navigation failed: $error');

    // Show user-friendly error message
    Get.snackbar(
      'Navigation Hatası',
      'Sayfa yüklenirken bir hata oluştu. Lütfen tekrar deneyin.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Utility methods for common navigation patterns
  Future<void> navigateAndClearStack(
    NavigationDestination destination, {
    Map<String, dynamic>? arguments,
  }) async {
    await navigateTo(destination, arguments: arguments, clearStack: true);
  }

  Future<void> navigateAndReplace(
    NavigationDestination destination, {
    Map<String, dynamic>? arguments,
  }) async {
    await navigateTo(destination, arguments: arguments, replace: true);
  }

  // Debug method to print current navigation stack
  void debugPrintNavigationStack() {
    print('NavigationService: Current route: ${Get.currentRoute}');
    print('NavigationService: Previous route: ${Get.routing.previous}');
    print(
        'NavigationService: Navigation stack depth: ${Get.routing.route?.navigator?.canPop()}');
  }
}
