import 'package:get/get.dart';

import '../controllers/chat_screen_chat_detail_screen_controller.dart';

class ChatScreenChatDetailScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatScreenChatDetailScreenController>(
      () => ChatScreenChatDetailScreenController(),
    );
  }
}
