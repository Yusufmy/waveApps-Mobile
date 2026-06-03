import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wive_app/app/common/get.dart';
import 'package:wive_app/app/utils/api.dart';

import '../../../../utils/format.dart';
import '../../../../utils/widgets/alert_global_widget.dart';

class ChatScreenChatDetailScreenController extends GetxController {
  TextEditingController messageController = TextEditingController();
  RxString messageText = "".obs;

  RxString name = "".obs; //NAME RECHIVER
  RxString photo = "".obs; //PHOTO RECHIVER
  RxString conversationId = "".obs; //ROOM ID
  RxString idUserRechiver = "".obs;
  RxInt idUserLogin = 0.obs;

  //FIREBASE REAL TIME
  final DatabaseReference db = FirebaseDatabase.instance.ref();
  StreamSubscription? presenceSub;
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  RxMap<String, List<Map<String, dynamic>>> groupedMessages =
      <String, List<Map<String, dynamic>>>{}.obs;
  StreamSubscription? messageSub;

  //STATUS RECHIVER
  RxString statusRechiver = "".obs;

  void updaDate() async {
    idUserLogin.value = await getId() ?? 0;
  }

  void updateStatusRechiver() async {
    presenceSub?.cancel();

    presenceSub = db.child("presence/${idUserRechiver.value}").onValue.listen((
      even,
    ) {
      if (!even.snapshot.exists) {
        statusRechiver.value = "Offline";
        return;
      }

      final data = Map<String, dynamic>.from(even.snapshot.value as Map);

      final bool online = data["online"] ?? false;

      if (online) {
        statusRechiver.value = "Online";
      } else {
        final lastSeen = data['last_seen'];

        statusRechiver.value = "Last seen ${formatLastSeen(lastSeen)}";
      }
    });
  }

  void updateMessage() async {
    messageSub?.cancel();

    messageSub = db.child("messages/${conversationId.value}").onValue.listen((
      event,
    ) {
      final data = event.snapshot.value;

      if (data == null) {
        messages.clear();
        groupedMessages.clear();
        return;
      }

      final Map raw = data as Map;

      final List<Map<String, dynamic>> loaded = [];

      raw.forEach((key, value) {
        loaded.add({"key": key, ...Map<String, dynamic>.from(value)});
      });

      loaded.sort(
        (a, b) => (a["created_at"] ?? 0).compareTo(b["created_at"] ?? 0),
      );

      messages.value = loaded;

      // 🔥 IMPORTANT: update RxMap properly
      groupedMessages.clear();

      for (var msg in loaded) {
        final ts = msg["created_at"] ?? 0;

        final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);

        final key = "${date.year}-${date.month}-${date.day}";

        groupedMessages.putIfAbsent(key, () => []);
        groupedMessages[key]!.add(msg);
      }

      groupedMessages.refresh(); // 🔥 IMPORTANT
    });
  }

  void sendMessage(BuildContext context, String conversionId) async {
    try {
      final text = messageController.text.trim();

      messageController.clear();

      final body = {"conversation_id": conversionId, "message": text};

      print("Request Body : $body");

      final res = await Api.sendMessage(body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        print("Berhasil di kirim : ${res.body}");
      } else {
        print("Gagal di kirim : ${res.body}");
      }
    } catch (e) {
      showAlert(context, text: "Terjadi kesalahan", isSuccess: false);

      print("Terjadi kesalahan : $e");
    }
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args['conversationId'] != null ||
        args['conversationId'].toString().isNotEmpty) {
      conversationId.value = args['conversationId'] ?? '';
    }

    if (args['name'] != null || args['name'].toString().isNotEmpty) {
      name.value = args['name'] ?? "";
    }

    if (args['photo'] != null || args['photo'].toString().isNotEmpty) {
      photo.value = args['photo'] ?? "";
    }
    if (args['idUserRechiver'] != null ||
        args['idUserRechiver'].toString().isNotEmpty) {
      idUserRechiver.value = args['idUserRechiver'] ?? "";
    }

    updaDate();
    updateStatusRechiver();
    updateMessage();

    messageController.addListener(() {
      messageText.value = messageController.text;
    });

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
}
