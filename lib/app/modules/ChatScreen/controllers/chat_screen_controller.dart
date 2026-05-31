import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../service/profile_core_service.dart';
import '../../CallScreen/views/call_screen_view.dart';
import '../../ProfileScreen/views/profile_screen_view.dart';
import '../views/chat_screen_view.dart';

class ChatScreenController extends GetxController {
  final userProfile = Get.find<ProfileCoreService>();
  
  List<Widget> listPage = [
    ChatScreenView(),
    CallScreenView(),
    ProfileScreenView(),
  ];

  RxInt currentPage = 0.obs;

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
