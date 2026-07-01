import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:wive_app/app/common/get.dart';
import 'package:wive_app/app/routes/app_pages.dart';
import 'package:wive_app/app/service/profile_core_service.dart';
import 'package:wive_app/app/service/zegoCall_service.dart';
import 'package:wive_app/app/utils/api.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../../../../../utils/colors.dart';

class CallDetailScreenController extends GetxController {
  final profile = Get.find<ProfileCoreService>();
  final callData = {}.obs;

  RxBool isCaller = false.obs;
  RxString callStatus = "ringing".obs;
  RxString typeCall = "".obs;

  RxBool isAcceptCall = false.obs;
  RxBool isRejectCall = false.obs;
  RxBool isEndCall = false.obs;
  StreamSubscription? _callStatusSub;

  RxString imageRechiver = "".obs;
  RxString nameRechiver = "".obs;

  RxString callDuration = "00:00".obs;
  Timer? callTimer;
  DateTime? callStartTime;

  RxInt localViewID = (-1).obs;
  RxInt remoteViewID = (-1).obs;

  RxBool isMicMuted = false.obs;
  RxBool isCameraOff = false.obs;
  RxBool isFrontCamera = true.obs;

  Future<void> toggleMute() async {
    try {
      isMicMuted.value = !isMicMuted.value;
      await ZegoExpressEngine.instance.muteMicrophone(isMicMuted.value);
      print("MIC MUTED => ${isMicMuted.value}");
    } catch (e) {
      print("TOGGLE MUTE ERROR => $e");
    }
  }

  Future<void> toggleCamera() async {
    try {
      isCameraOff.value = !isCameraOff.value;
      await ZegoExpressEngine.instance.enableCamera(!isCameraOff.value);
      print("CAMERA OFF => ${isCameraOff.value}");
    } catch (e) {
      print("TOGGLE CAMERA ERROR => $e");
    }
  }

  Future<void> switchCamera() async {
    try {
      isFrontCamera.value = !isFrontCamera.value;
      await ZegoExpressEngine.instance.useFrontCamera(isFrontCamera.value);
      print("FRONT CAMERA => ${isFrontCamera.value}");
    } catch (e) {
      print("SWITCH CAMERA ERROR => $e");
    }
  }

  // Future<void> _destroyVideoViews() async {
  //   try {
  //     if (localViewID.value != -1) {
  //       await ZegoExpressEngine.instance.destroyCanvasView(localViewID.value);
  //       localViewID.value = -1;
  //     }
  //     if (remoteViewID.value != -1) {
  //       await ZegoExpressEngine.instance.destroyCanvasView(remoteViewID.value);
  //       remoteViewID.value = -1;
  //     }
  //   } catch (e) {
  //     print("DESTROY VIEW ERROR => $e");
  //   }
  // }

  // Future<void> _createVideoViews() async {
  //   // Destroy dulu yang lama
  //   await _destroyVideoViews();

  //   final localCompleter = Completer<int>();
  //   final remoteCompleter = Completer<int>();

  //   await ZegoExpressEngine.instance.createCanvasView((viewID) {
  //     print("LOCAL VIEW CREATED => $viewID");
  //     localViewID.value = viewID;
  //     localCompleter.complete(viewID);
  //   });

  //   await ZegoExpressEngine.instance.createCanvasView((viewID) {
  //     print("REMOTE VIEW CREATED => $viewID");
  //     remoteViewID.value = viewID;
  //     remoteCompleter.complete(viewID);
  //   });

  //   await Future.wait([localCompleter.future, remoteCompleter.future]);

  //   // Tunggu Flutter render Texture widget dengan ID baru
  //   await Future.delayed(const Duration(milliseconds: 800));

  //   print(
  //     "VIEWS READY => local=${localViewID.value} remote=${remoteViewID.value}",
  //   );
  // }

  void startCallTimer() {
    // Jangan start lagi kalau sudah jalan
    if (callTimer != null && callTimer!.isActive) return;

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
        await _cleanupCall();

        await FirebaseDatabase.instance
            .ref("calls")
            .child(idCall.toString())
            .update({"status": "ended"});

        Get.back();
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark, // Android
            statusBarBrightness: Brightness.light, // iOS
            // Navigation Bar
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarDividerColor: Colors.white,
          ),
        );
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

  // FIX: Satu fungsi cleanup untuk semua kondisi
  Future<void> _cleanupCall() async {
    callTimer?.cancel();
    FlutterRingtonePlayer().stop();

    final roomID = callData["room_id"]?.toString();
    if (roomID != null) {
      await ZegoCallService.instance.leaveRoom(roomID);
    }

    // await _destroyVideoViews();
    await ZegoCallService.instance.destroyEngine();
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
              SystemChrome.setSystemUIOverlayStyle(
                const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark, // Android
                  statusBarBrightness: Brightness.light, // iOS
                  // Navigation Bar
                  systemNavigationBarColor: Colors.white,
                  systemNavigationBarIconBrightness: Brightness.dark,
                  systemNavigationBarDividerColor: Colors.white,
                ),
              );
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

    if (isCaller.value) {
      _joinRoomAsCaller();
    }

    print("=== CALL DATA LENGKAP ===");
    print(callData);
    print("room_id: ${callData["room_id"]}");
    print("isCaller: ${callData["isCaller"]}");
    print("IS CALLER => ${isCaller.value}");
    print("=========================");

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.blueColor,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: AppColors.blueColor,
      ),
    );
  }

  @override
  void onClose() {
    _callStatusSub?.cancel();
    // _cleanupCall tidak bisa di-await di onClose
    // tapi pastikan minimal cancel timer dan stop ringtone
    callTimer?.cancel();
    FlutterRingtonePlayer().stop();

    final roomID = callData["room_id"]?.toString();
    if (roomID != null) {
      ZegoCallService.instance.leaveRoom(roomID).then((_) async {
        // await _destroyVideoViews();
        await ZegoCallService.instance.destroyEngine();
      });
    }

    super.onClose();
  }
}
