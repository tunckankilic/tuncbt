import 'package:get/get.dart';
import 'package:tuncbt/screens/tasks_screen/tasks_screen_controller.dart';

class TasksScreenBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TasksScreenController());
  }
}
