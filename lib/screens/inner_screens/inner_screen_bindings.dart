import 'package:get/get.dart';
import 'package:tuncbt/screens/inner_screens/inner_screen_controller.dart';

class InnerScreenBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InnerScreenController());
  }
}
