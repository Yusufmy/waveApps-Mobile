import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    SplashScreenController controller = Get.put(SplashScreenController());
    return Scaffold(
      body: Obx(
        () => Center(
          child: Image.asset(controller.image.value, width: 180, height: 180),
        ),
      ),
    );
  }
}
