import 'package:get/get.dart';

class AllWorkersBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AllWorkersBindings());
  }
}
