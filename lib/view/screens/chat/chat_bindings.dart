import 'package:get/get.dart';
import 'package:tuncbt/view/screens/chat/chat_controller.dart';

class ChatBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController());
  }
}
