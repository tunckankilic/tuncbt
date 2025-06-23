// bindings.dart
import 'package:get/get.dart';
import 'package:tuncbt/view/screens/chat/chat_controller.dart';
import 'package:tuncbt/view/screens/users/users_controller.dart';
import 'package:tuncbt/view/screens/users/users_repository.dart';

class UsersBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserRepository());
    Get.lazyPut(() => UserController(Get.find<UserRepository>()));
    Get.lazyPut(() => ChatController());
  }
}
