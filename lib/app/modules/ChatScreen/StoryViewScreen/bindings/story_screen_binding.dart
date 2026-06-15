import 'package:get/get.dart';

import '../controllers/story_screen_controller.dart';

class ChatScreenStoryViewScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoryScreenController>(
      () => StoryScreenController(),
    );
  }
}
