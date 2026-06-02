import 'package:get/get.dart';
import 'package:wive_app/app/common/get.dart';
import 'package:wive_app/app/routes/app_pages.dart';

import '../../../utils/systemChrome.dart';

class SplashScreenController extends GetxController {
  RxString image = "assets/images/logoWiveApp.png".obs;

  void splashScreen() async {
    try {
      print("SPLASH START");

      await Future.delayed(const Duration(seconds: 2));

      final token = await getToken();

      print("TOKEN : $token");

      if (token != null && token.isNotEmpty) {
        print("GO TO CHAT");

        Get.offAllNamed(Routes.CHAT_SCREEN);
      } else {
        print("GO TO WELCOME");

        Get.offAllNamed(Routes.WELCOME_SCREEN);
      }
    } catch (e, stack) {
      print("ERROR SPLASH : $e");
      print(stack);
    }
  }

  @override
  void onInit() {
    super.onInit();
    SystemChromeConfig.setLightNavigationBar();

    print("INIT SPLASH");

    splashScreen();
  }
}
