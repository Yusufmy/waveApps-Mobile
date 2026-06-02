import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ChatScreenChatDetailScreenController extends GetxController {
  RxString name = "Alexander".obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,

        // ICON PUTIH
        statusBarIconBrightness: Brightness.light,

        // IOS
        statusBarBrightness: Brightness.dark,

        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android
        statusBarBrightness: Brightness.light, // iOS
      ),
    );
    super.onClose();
  }

  void increment() => count.value++;
}
