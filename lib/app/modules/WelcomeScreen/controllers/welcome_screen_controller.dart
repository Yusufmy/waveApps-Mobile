import 'package:get/get.dart';

import '../../../utils/systemChrome.dart';

class WelcomeScreenController extends GetxController {
  

  final count = 0.obs;
  @override
  void onInit() {
    SystemChromeConfig.setLightNavigationBar();
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
