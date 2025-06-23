import 'package:get/get.dart';
import 'package:tuncbt/view/screens/auth/auth_controller.dart';

class AuthBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
  }
}
