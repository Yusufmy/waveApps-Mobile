import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:wive_app/app/common/get.dart';
import 'package:wive_app/app/utils/api.dart';

import '../../../../../utils/call_center.dart';

class CallDetailScreenController extends GetxController {
  final callData = {}.obs;

  RxBool isCaller = false.obs;

  RxString callStatus = "ringing".obs;

  RxBool isAcceptCall = false.obs;
  RxBool isRejectCall = false.obs;
  RxBool isEndCall = false.obs;

  Future<void> acceptCall(var idCall) async {
    if (isAcceptCall.value) return;

    try {
      isAcceptCall.value = true;

      final userLoginId = await getId();
      final userNameLogin = await getName();

      final res = await Api.acceptCallUrl(idCall);

      if (res.statusCode == 200 || res.statusCode == 201) {
        callStatus.value = "accepted";

        print("Berhasil menerima : ${res.body}");

        FlutterRingtonePlayer().stop();

        print("ROOMID : ${callData["room_id"]}");

        await FirebaseDatabase.instance
            .ref("calls")
            .child(idCall.toString())
            .update({"status": "accepted"});

        Get.off(
          () => VoiceCallPage(
            roomID: callData["room_id"],
            userID: "$userLoginId",
            userName: "$userNameLogin",
          ),
        );
      } else {
        print("Gagal accept : ${res.body}");
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    } finally {
      isAcceptCall.value = false;
    }
  }

  Future<void> rejectCall(var idCall) async {
    if (isRejectCall.value) return;

    try {
      isRejectCall.value = true;

      final res = await Api.rejectCallUrl(idCall);

      if (res.statusCode == 200 || res.statusCode == 201) {
        FlutterRingtonePlayer().stop();
        Get.back();

        print("Berhasil reject : ${res.body}");
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    } finally {
      isRejectCall.value = false;
    }
  }

  Future<void> endtCall(var idCall) async {
    if (isEndCall.value) return;

    try {
      isEndCall.value = true;

      final res = await Api.endCallUrl(idCall);

      if (res.statusCode == 200 || res.statusCode == 201) {
        FlutterRingtonePlayer().stop();
        Get.back();

        print("Berhasil end : ${res.body}");
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    } finally {
      isEndCall.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();

    callData.value = Get.arguments ?? {};

    isCaller.value = callData["isCaller"] ?? false;

    callStatus.value = callData["status"] ?? "ringing";

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
    super.onClose();
  }
}
