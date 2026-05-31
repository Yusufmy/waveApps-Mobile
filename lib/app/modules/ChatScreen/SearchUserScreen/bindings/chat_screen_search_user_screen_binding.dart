import 'package:get/get.dart';

import '../controllers/chat_screen_search_user_screen_controller.dart';

class ChatScreenSearchUserScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatScreenSearchUserScreenController>(
      () => ChatScreenSearchUserScreenController(),
    );
  }
}
