import 'package:get/get.dart';

import '../controllers/call_detail_screen_controller.dart';

class CallDetailScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallDetailScreenController>(
      () => CallDetailScreenController(),
    );
  }
}
