import 'package:get/get.dart';
import 'package:tuncbt/screens/all_workers/all_workers_controller.dart';

class AllWorkersBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AllWorkersController());
  }
}
