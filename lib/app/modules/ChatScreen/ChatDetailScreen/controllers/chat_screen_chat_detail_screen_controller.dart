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
  ///MESSAGE CHAT
  TextEditingController messageController = TextEditingController();
  RxString messageText = "".obs;
  RxBool isTyping = false.obs;
  Timer? typingTimer;
  StreamSubscription? typingSub;

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

  //MESSAGE LOKAL
  RxList<Map<String, dynamic>> localMessages = <Map<String, dynamic>>[].obs;

  //STATUS RECHIVER
  RxString statusRechiver = "".obs;

  //SCROLL
  ScrollController scrollController = ScrollController();

  void scrollLastMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      scrollController.jumpTo(scrollController.position.maxScrollExtent);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!scrollController.hasClients) return;

        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    });
  }

  void updaDate() async {
    idUserLogin.value = await getId() ?? 0;
  }

  Future<void> updateTyping(bool typing) async {
    try {
      await db.child("typing/${conversationId.value}/${idUserLogin.value}").set(
        {"typing": typing, "updated_at": ServerValue.timestamp},
      );
    } catch (e) {
      print("Typing Error : $e");
    }
  }

  void listenTyping() {
    typingSub?.cancel();

    typingSub = db
        .child("typing/${conversationId.value}/${idUserRechiver.value}")
        .onValue
        .listen((event) {
          if (!event.snapshot.exists) {
            isTyping.value = false;
            return;
          }

          final data = Map<String, dynamic>.from(event.snapshot.value as Map);

          isTyping.value = data["typing"] ?? false;
        });
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

  void updateMessage() {
    messageSub?.cancel();

    messageSub = db.child("messages/${conversationId.value}").onValue.listen((
      event,
    ) async {
      final data = event.snapshot.value;

      final List<Map<String, dynamic>> firebaseMessages = [];

      if (data != null) {
        final Map raw = data as Map;

        raw.forEach((key, value) {
          firebaseMessages.add({
            "key": key,
            ...Map<String, dynamic>.from(value),
          });
        });

        firebaseMessages.sort(
          (a, b) => (a["created_at"] ?? 0).compareTo(b["created_at"] ?? 0),
        );
      }

      // ==========================
      // HAPUS TEMP MESSAGE
      // YANG SUDAH MASUK FIREBASE
      // ==========================

      for (final firebaseMsg in firebaseMessages) {
        localMessages.removeWhere(
          (local) =>
              local["message"] == firebaseMsg["message"] &&
              local["sender_id"].toString() ==
                  firebaseMsg["sender_id"].toString(),
        );
      }

      // ==========================
      // GABUNGKAN
      // ==========================

      final mergedMessages = [...firebaseMessages, ...localMessages];

      mergedMessages.sort(
        (a, b) => (a["created_at"] ?? 0).compareTo(b["created_at"] ?? 0),
      );

      messages.value = mergedMessages;

      // ==========================
      // DELIVERED
      // ==========================

      final List<int> messageIds = [];

      for (final msg in firebaseMessages) {
        final isMe =
            msg['sender_id'].toString() == idUserLogin.value.toString();

        if (!isMe && msg['status'] == 'sent') {
          messageIds.add(int.parse(msg['message_id'].toString()));
        }
      }

      if (messageIds.isNotEmpty) {
        deliveredMessage(messageIds);
      }

      // ==========================
      // GROUP BY DATE
      // ==========================

      groupedMessages.clear();

      for (final msg in mergedMessages) {
        final ts = msg["created_at"] ?? 0;

        final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);

        final key = "${date.year}-${date.month}-${date.day}";

        groupedMessages.putIfAbsent(key, () => []);

        groupedMessages[key]!.add(msg);
      }

      groupedMessages.refresh();

      scrollLastMessage();
    });
  }

  Future<void> deliveredMessage(List<int> messageIds) async {
    try {
      if (messageIds.isEmpty) return;

      final body = {"message_ids": messageIds};

      print("DELIVERED => $body");

      final res = await Api.deliveredMessage(body);

      print("DELIVERED RESPONSE => ${res.body}");
    } catch (e) {
      print("Terjadi kesalahan delivered : $e");
    }
  }

  void sendMessage(BuildContext context, String conversationId) async {
    final text = messageController.text.trim();

    await updateTyping(false);

    if (text.isEmpty) return;

    messageController.clear();

    final tempId = "temp_${DateTime.now().millisecondsSinceEpoch}";

    final tempMessage = {
      "temp_id": tempId,
      "message": text,
      "sender_id": idUserLogin.value,
      "created_at": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "status": "sending",
      "is_local": true,
    };

    // ==========================
    // TAMBAH KE LIST LOKAL
    // ==========================

    localMessages.add(tempMessage);

    messages.add(tempMessage);

    rebuildGroupedMessages();

    scrollLastMessage();

    try {
      final body = {"conversation_id": conversationId, "message": text};

      final res = await Api.sendMessage(body);

      if (res.statusCode != 200 && res.statusCode != 201) {
        final index = localMessages.indexWhere((e) => e["temp_id"] == tempId);

        if (index != -1) {
          localMessages[index]["status"] = "failed";

          localMessages.refresh();

          rebuildGroupedMessages();
        }
      }
    } catch (e) {
      final index = localMessages.indexWhere((e) => e["temp_id"] == tempId);

      if (index != -1) {
        localMessages[index]["status"] = "failed";

        localMessages.refresh();

        rebuildGroupedMessages();
      }
    }
  }

  void rebuildGroupedMessages() {
    groupedMessages.clear();

    for (final msg in messages) {
      final ts = msg["created_at"] ?? 0;

      final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);

      final key = "${date.year}-${date.month}-${date.day}";

      groupedMessages.putIfAbsent(key, () => []);

      groupedMessages[key]!.add(msg);
    }

    groupedMessages.refresh();
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
    listenTyping();

    messageController.addListener(() {
      messageText.value = messageController.text;

      updateTyping(true);

      typingTimer?.cancel();

      typingTimer = Timer(const Duration(seconds: 2), () {
        updateTyping(false);
      });
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
