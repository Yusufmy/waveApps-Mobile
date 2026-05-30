import 'package:get/get.dart';

import '../../../service/profile_core_service.dart';

class ProfileScreenController extends GetxController {
  final userProfile = Get.find<ProfileCoreService>();

  RxBool isNotification = false.obs;
  RxBool isLogout = false.obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
