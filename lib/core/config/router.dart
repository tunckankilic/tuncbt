import 'package:get/get.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/view/screens/auth/screens/auth.dart';
import 'package:tuncbt/view/screens/auth/screens/password_renew.dart';
import 'package:tuncbt/view/screens/bindings.dart';
import 'package:tuncbt/view/screens/chat/chat_screen.dart';
import 'package:tuncbt/view/screens/screens.dart';
import 'package:tuncbt/view/screens/users/users_bindings.dart';
import 'package:tuncbt/view/screens/users/users_repository.dart';
import 'package:tuncbt/view/screens/users/users_screen.dart';

class RouteManager {
  static const String home = '/home';
  static const String login = '/login';
  static const String settings = '/settings';

  static List<GetPage> routes = [
    GetPage(
      name: AllWorkersScreen.routeName,
      page: () => AllWorkersScreen(),
      binding: AllWorkersBindings(),
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
      name: UploadTask.routeName,
      page: () => UploadTask(),
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
        name: UploadTask.routeName,
        page: () => UploadTask(),
        binding: TasksScreenBindings()),
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
      name: '/chat',
      page: () => ChatScreen(receiver: Get.arguments as UserModel),
    ),
  ];

  static String getInitialRoute() {
    // Logic to determine the initial route
    // For example, check if user is logged in
    bool isLoggedIn = false; // This should be your actual login check
    return isLoggedIn ? home : login;
  }
}
