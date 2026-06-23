import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wive_app/app/utils/api.dart';

import '../../../service/profile_core_service.dart';

class CallScreenController extends GetxController {
  final userProfile = Get.find<ProfileCoreService>();

  RxList historyCallList = [].obs;

  Map<String, dynamic> getOpponent(Map<String, dynamic> call) {
    final myId = userProfile.id.value;

    if (call['caller_id'] == myId) {
      return call['receiver'];
    }

    return call['caller'];
  }

  IconData getCallIcon(dynamic call) {
  switch (call['status']) {
    case 'rejected':
      return Icons.call_missed;

    case 'missed':
      return Icons.call_missed;

    case 'ended':
      return call['caller_id'] == userProfile.id.value
          ? Icons.call_made
          : Icons.call_received;

    default:
      return Icons.call;
  }
}

Color getCallIconColor(dynamic call) {
  switch (call['status']) {
    case 'rejected':
      return Colors.red;

    case 'missed':
      return Colors.red;

    case 'ended':
      return Colors.green;

    default:
      return Colors.grey;
  }
}

  void getHistoryCall() async {
    try {
      final res = await Api.getHistoryCallUrl();
      final resJson = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        historyCallList.assignAll(resJson['data']['data']);
        print("RESPONSE BODY : ${res.body}");
      } else {
        print("Gagal mengambil data : ${res.body}");
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    }
  }

  final count = 0.obs;
  @override
  void onInit() {
    getHistoryCall();
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
