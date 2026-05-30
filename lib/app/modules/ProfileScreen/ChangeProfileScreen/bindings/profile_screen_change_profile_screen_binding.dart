import 'package:get/get.dart';

import '../controllers/profile_screen_change_profile_screen_controller.dart';

class ProfileScreenChangeProfileScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileScreenChangeProfileScreenController>(
      () => ProfileScreenChangeProfileScreenController(),
    );
  }
}
