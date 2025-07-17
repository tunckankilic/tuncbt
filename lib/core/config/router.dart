import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/view/screens/all_workers/all_workers.dart';
import 'package:tuncbt/view/screens/all_workers/all_workers_bindings.dart';
import 'package:tuncbt/view/screens/auth/auth_bindings.dart';
import 'package:tuncbt/view/screens/auth/screens/auth.dart';
import 'package:tuncbt/view/screens/auth/screens/forget_pass.dart';
import 'package:tuncbt/view/screens/auth/screens/login.dart';
import 'package:tuncbt/view/screens/auth/screens/password_renew.dart';
import 'package:tuncbt/view/screens/auth/screens/referral_input.dart';
import 'package:tuncbt/view/screens/auth/screens/register.dart';
import 'package:tuncbt/view/screens/chat/chat_bindings.dart';
import 'package:tuncbt/view/screens/chat/chat_index.dart';
import 'package:tuncbt/view/screens/chat/chat_screen.dart';
import 'package:tuncbt/view/screens/chat/group_members_screen.dart';
import 'package:tuncbt/view/screens/inner_screens/inner_screen_bindings.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/invite_members.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/profile.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/task_details.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/team_settings.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/upload_task.dart';
import 'package:tuncbt/view/screens/legal/privacy_policy.dart';
import 'package:tuncbt/view/screens/legal/terms_of_service.dart';
import 'package:tuncbt/view/screens/tasks_screen/screens/tasks_screen.dart';
import 'package:tuncbt/view/screens/tasks_screen/tasks_screen_bindings.dart';
import 'package:tuncbt/view/screens/users/users_bindings.dart';
import 'package:tuncbt/view/screens/users/users_screen.dart';
import 'package:tuncbt/core/services/auth_service.dart';

class RouteManager {
  static const String home = '/home';
  static const String login = '/login';
  static const String settings = '/settings';
  static const String tasks = '/tasks';
  static const String uploadTask = '/upload-task';

  static final routes = [
    GetPage(
      name: tasks,
      page: () => const TasksScreen(),
      binding: TasksScreenBindings(),
    ),
    GetPage(
      name: uploadTask,
      page: () => UploadTaskScreen(),
      binding: InnerScreenBindings(),
    ),
    GetPage(
      name: AllWorkersScreen.routeName,
      page: () => AllWorkersScreen(),
      binding: AllWorkersBindings(),
    ),
    GetPage(
      name: TeamSettingsScreen.routeName,
      page: () => const TeamSettingsScreen(),
      binding: InnerScreenBindings(),
    ),
    GetPage(
      name: ForgetPasswordScreen.routeName,
      page: () => ForgetPasswordScreen(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: AuthScreen.routeName,
      page: () => AuthScreen(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: UploadTaskScreen.routeName,
      page: () => UploadTaskScreen(),
      binding: InnerScreenBindings(),
    ),
    GetPage(
      name: ProfileScreen.routeName,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return ProfileScreen(
          userId: args?['userId'] as String? ?? '',
          userType: args?['userType'] as UserType? ?? UserType.currentUser,
        );
      },
      binding: InnerScreenBindings(),
    ),
    GetPage(
      name: TaskDetailsScreen.routeName,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return TaskDetailsScreen(
          teamId: args['teamId'],
          uploadedBy: args['uploadedBy'] as String,
          taskID: args['taskID'] as String,
        );
      },
      binding: InnerScreenBindings(),
    ),
    GetPage(
      name: TasksScreen.routeName,
      page: () => TasksScreen(),
      binding: TasksScreenBindings(),
    ),
    GetPage(
        name: UploadTaskScreen.routeName,
        page: () => UploadTaskScreen(),
        binding: InnerScreenBindings()),
    GetPage(
      name: PasswordRenew.routeName,
      page: () => PasswordRenew(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: '/users',
      page: () => const UsersListView(),
      binding: UsersBindings(),
    ),
    GetPage(
      name: ChatScreen.routeName,
      page: () => ChatScreen(receiver: Get.arguments as UserModel),
      binding: ChatBindings(),
    ),
    GetPage(
      name: ChatIndexScreen.routeName,
      page: () => const ChatIndexScreen(),
      binding: ChatBindings(),
    ),
    GetPage(
      name: '/login',
      page: () => Login(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: '/auth/register',
      page: () => SignUp(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: '/auth/referral',
      page: () => ReferralInputScreen(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: '/auth/password-reset',
      page: () => PasswordRenew(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: '/tasks',
      page: () => TasksScreen(),
      binding: TasksScreenBindings(),
      middlewares: [
        RouteGuard(),
      ],
    ),
    GetPage(
      name: InviteMembersScreen.routeName,
      page: () => InviteMembersScreen(),
      binding: InnerScreenBindings(),
    ),
    GetPage(
      name: '/privacy-policy',
      page: () => const PrivacyPolicyScreen(),
    ),
    GetPage(
      name: '/terms-of-service',
      page: () => const TermsOfServiceScreen(),
    ),
    GetPage(
      name: '/group-members',
      page: () => GroupMembersScreen(),
      binding: ChatBindings(),
    ),
  ];
}

class RouteGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.hasTeam.value && route != '/auth/referral') {
      return const RouteSettings(name: '/auth/referral');
    }
    return null;
  }
}
