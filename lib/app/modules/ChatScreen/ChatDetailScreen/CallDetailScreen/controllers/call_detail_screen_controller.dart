import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:wive_app/app/common/get.dart';
import 'package:wive_app/app/routes/app_pages.dart';
import 'package:wive_app/app/service/zegoCall_service.dart';
import 'package:wive_app/app/utils/api.dart';

class CallDetailScreenController extends GetxController {
  final callData = {}.obs;

  RxBool isCaller = false.obs;

  RxString callStatus = "ringing".obs;
  RxString typeCall = "".obs;

  RxBool isAcceptCall = false.obs;
  RxBool isRejectCall = false.obs;
  RxBool isEndCall = false.obs;
  StreamSubscription? _callStatusSub; // ← tambahkan

  ///IMAGE USER
  RxString imageRechiver = "".obs;
  RxString nameRechiver = "".obs;

  ///DURATION
  RxString callDuration = "00:00".obs;

  Timer? callTimer;
  DateTime? callStartTime;

  void startCallTimer() {
    callTimer?.cancel();

    callStartTime = DateTime.now();

    callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final duration = DateTime.now().difference(callStartTime!);

      final minutes = duration.inMinutes.toString().padLeft(2, '0');

      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

      callDuration.value = "$minutes:$seconds";
    });
  }

  Future<void> acceptCall(var idCall) async {
    if (isAcceptCall.value) return;

    print("===== ACCEPT DIPENCET =====");
    print("CALL ID : $idCall");

    try {
      isAcceptCall.value = true;

      final userLoginId = await getId();
      final userNameLogin = await getName();

      final res = await Api.acceptCallUrl(idCall);

      if (res.statusCode == 200 || res.statusCode == 201) {
        callStatus.value = "accepted";

        final roomID = callData["room_id"].toString();

        await ZegoCallService.instance.joinRoom(
          roomID: roomID,
          userID: "$userLoginId",
          userName: "$userNameLogin",
          type: typeCall.value,
        );

        startCallTimer();

        FlutterRingtonePlayer().stop();

        await FirebaseDatabase.instance
            .ref("calls")
            .child(idCall.toString())
            .update({"status": "accepted"});
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

        await FirebaseDatabase.instance
            .ref("calls")
            .child(idCall.toString())
            .update({"status": "rejected"});

        Get.back();

        print("Berhasil reject : ${res.body}");
      } else {
        print("Gagal reject : ${res.body}");
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
        await ZegoCallService.instance.leaveRoom(
          callData["room_id"].toString(),
        );

        await FirebaseDatabase.instance
            .ref("calls")
            .child(idCall.toString())
            .update({"status": "ended"});

        callTimer?.cancel();

        FlutterRingtonePlayer().stop();

        Get.back();

        print("Berhasil end : ${res.body}");
      } else {
        print("Gagal end : ${res.body}");
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    } finally {
      isEndCall.value = false;
    }
  }

  void _listenCallStatus(String callId) {
    _callStatusSub?.cancel();

    _callStatusSub = FirebaseDatabase.instance
        .ref("calls")
        .child(callId)
        .onValue
        .listen((event) async {
          if (event.snapshot.value == null) return;

          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final status = data["status"];
          callStatus.value = status ?? "ringing";

          print("CALL DETAIL STATUS => $status");

          // JALANKAN TIMER SAAT STATUS BERUBAH KE ACCEPTED
          if (status == "accepted") {
            startCallTimer();
          }

          // HAPUS join room dari sini — jangan ada ZegoCallService di sini
          // User A sudah join di _joinRoomAsCaller()
          // User B join di acceptCall()

          if (status == "ended" || status == "rejected") {
            final roomID =
                data["room_id"]?.toString() ?? callData["room_id"]?.toString();

            if (roomID != null) {
              await ZegoCallService.instance.leaveRoom(roomID);
            }

            FlutterRingtonePlayer().stop();
            _callStatusSub?.cancel();
            _callStatusSub?.cancel();

            if (Get.currentRoute == Routes.CALL_DETAIL_SCREEN) {
              Get.back();
            }
          }
        });
  }

  Future<void> _joinRoomAsCaller() async {
    try {
      final userLoginId = await getId();
      final userNameLogin = await getName();
      final roomID = callData["room_id"]?.toString();

      print("================================");
      print("CALLER JOIN ROOM");
      print("ROOM ID : $roomID");
      print("USER ID : $userLoginId");
      print("================================");
      print("CALLER AKAN JOIN ROOM_ID = $roomID");

      await ZegoCallService.instance.joinRoom(
        roomID: roomID!,
        userID: "$userLoginId",
        userName: "$userNameLogin",
        type: typeCall.value,
      );

      print("CALLER JOIN SUCCESS");
    } catch (e) {
      print("CALLER JOIN ERROR => $e");
    }
  }

  @override
  void onInit() {
    super.onInit();

    callData.value = Get.arguments ?? {};
    isCaller.value = callData["isCaller"] ?? false;
    callStatus.value = callData["status"] ?? "ringing";
    imageRechiver.value = callData["imageRechiver"] ?? "";
    nameRechiver.value = callData["nameRechiver"] ?? "";
    typeCall.value = callData["type"] ?? "";

    print("SAAT MEMBUKA PAGE : ${callData}");
    print("SAAT MEMBUKA PAGE : ${isCaller.value}");
    print("SAAT MEMBUKA PAGE : ${callStatus.value}");

    final rawId = callData["id"] ?? callData["call_id"];
    if (rawId != null) {
      callData["_resolvedCallId"] = rawId.toString();
    }

    final resolvedId = callData["_resolvedCallId"];
    if (resolvedId != null) {
      _listenCallStatus(resolvedId);
    }

    // HANYA caller yang auto join
    // User B (isCaller: false) join HANYA saat tekan accept
    if (isCaller.value) {
      _joinRoomAsCaller();
    }
    // Tidak ada else di sini — User B tunggu tombol accept ditekan

    print("=== CALL DATA LENGKAP ===");
    print(callData);
    print("room_id: ${callData["room_id"]}");
    print("isCaller: ${callData["isCaller"]}");
    print("IS CALLER => ${isCaller.value}");
    print("=========================");

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void onClose() {
    callTimer?.cancel();
    super.onClose();
  }
}
