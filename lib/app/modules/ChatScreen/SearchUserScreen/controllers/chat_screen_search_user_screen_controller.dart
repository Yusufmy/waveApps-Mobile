import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../service/profile_core_service.dart';
import '../../../../utils/api.dart';
import '../../../../utils/widgets/alert_global_widget.dart';

class ChatScreenSearchUserScreenController extends GetxController {
  final userProfile = Get.find<ProfileCoreService>();

  TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;
  RxList searchResults = [].obs;

  RxBool isLoadingSearch = false.obs;
  RxBool isLoadingRecentChats = false.obs;
  RxBool isLoadingAddUser = false.obs;
  RxList recentChats = [].obs;

  Future<void> searchUsers(BuildContext context, String keyword) async {
    try {
      isLoadingSearch.value = true;
      final res = await Api.getSearchUser(keyword);
      final resJson = jsonDecode(res.body);

      if (res.statusCode == 200) {
        searchResults.value = resJson['data']['data'];
      } else {
        showAlert(context, text: "${resJson['message']}", isSuccess: false);
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    } finally {
      isLoadingSearch.value = false;
    }
  }

  Future<void> getRecentChats(BuildContext context) async {
    try {
      isLoadingRecentChats.value = true;
      final res = await Api.getConversations();
      final resJson = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        recentChats.value = resJson['data'];
      } else {
        showAlert(context, text: "${resJson['message']}", isSuccess: false);
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    } finally {
      isLoadingRecentChats.value = false;
    }
  }

  Future<void> postConvercation(BuildContext context, var idUser) async {
    if (isLoadingAddUser.value) return;
    try {
      isLoadingAddUser.value = true;
      final body = {"user_id": idUser};

      final res = await Api.postConversations(body);
      final resJson = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        showAlert(context, text: "${resJson['message']}", isSuccess: true);
        getRecentChats(context);
        Get.toNamed(Routes.CHAT_DETAIL_SCREEN);
      } else {
        showAlert(context, text: "${resJson['message']}", isSuccess: false);
      }
    } catch (e) {
      showAlert(context, text: "Terjadi kesalahan", isSuccess: false);
      print("Terjadi kesalahan : $e");
    } finally {
      isLoadingAddUser.value = false;
    }
  }

  final count = 0.obs;
  @override
  void onInit() {
    getRecentChats(Get.context!);
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });

    debounce(searchQuery, (value) {
      if (value.toString().trim().isNotEmpty) {
        searchUsers(Get.context!, value.toString().trim());
      } else {
        searchResults.clear();
      }
    }, time: const Duration(milliseconds: 500));

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
