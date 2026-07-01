import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wive_app/app/common/get.dart';
import 'package:wive_app/app/routes/app_pages.dart';
import 'package:wive_app/app/service/zegoCall_service.dart';
import 'package:wive_app/app/utils/api.dart';

import '../../../../utils/call_center.dart';
import '../../../../utils/format.dart';
import '../../../../utils/widgets/alert_global_widget.dart';

class ChatScreenChatDetailScreenController extends GetxController {
  ///MESSAGE CHAT
  TextEditingController messageController = TextEditingController();
  RxString messageText = "".obs;
  RxBool isTyping = false.obs;
  Timer? typingTimer;
  StreamSubscription? typingSub;

  ///EMOJI
  final isEmojiVisible = false.obs;
  final messageFocus = FocusNode();

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

  //VARIABEL CALL
  RxBool isStartCall = false.obs;
  StreamSubscription? callStatusSub;
  RxString callStatus = "ringing".obs;

  //VOICE
  final RecorderController recorderController = RecorderController();
  RxBool isShowVoiceWave = false.obs;
  RxBool isRecording = false.obs;
  RxString recordPath = "".obs;
  RxInt duration = 0.obs;
  Timer? recordTimer;
  // final PlayerController playerController = PlayerController();
  // final stopVoice = false.obs;
  RxnString currentPlayingAudioId = RxnString();
  PlayerController? _activePlayer;

  void registerActivePlayer(String id, PlayerController controller) {
    _activePlayer = controller;
  }

  Future<void> stopCurrentAudio() async {
    try {
      await _activePlayer?.pausePlayer();
    } catch (_) {}
    currentPlayingAudioId.value = null;
    _activePlayer = null;
  }

  void toggleEmoji(BuildContext context) {
    if (isEmojiVisible.value) {
      isEmojiVisible.value = false;
      FocusScope.of(context).requestFocus(messageFocus);
    } else {
      FocusScope.of(context).unfocus();
      isEmojiVisible.value = true;
    }
  }

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

  Future<void> sendMessage({
    required BuildContext context,
    required String conversationId,

    String message = "",
    String messageType = "text",

    File? file,
    int? duration,
  }) async {
    debugPrint("========== SEND MESSAGE ==========");
    debugPrint("Conversation : $conversationId");
    debugPrint("Type         : $messageType");
    debugPrint("Message      : $message");
    debugPrint("File         : ${file?.path}");
    debugPrint("Duration     : $duration");

    debugPrint("[1] Update typing...");
    await updateTyping(false);

    debugPrint("[2] Validasi message...");
    if (messageType == "text" && message.trim().isEmpty) {
      debugPrint("❌ Text kosong");
      return;
    }

    final tempId = "temp_${DateTime.now().millisecondsSinceEpoch}";

    debugPrint("[3] Temp ID : $tempId");

    if (messageType == "text") {
      debugPrint("[4] Clear Text Controller");
      messageController.clear();
    }

    int? fileSize;

    if (file != null) {
      debugPrint("[5] Ambil ukuran file...");
      fileSize = await file.length();

      debugPrint("Nama File : ${file.path.split("/").last}");
      debugPrint("Ukuran    : $fileSize bytes");
    }

    final tempMessage = {
      "temp_id": tempId,
      "conversation_id": conversationId,
      "sender_id": idUserLogin.value,
      "message": message,
      "message_type": messageType,
      "attachment_url": file?.path,
      "duration": duration,
      "file_name": file?.path.split("/").last,
      "file_size": fileSize,
      "status": "sending",
      "created_at": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "is_local": true,
    };

    debugPrint("[6] Tambah ke Local Message");
    localMessages.add(tempMessage);

    debugPrint("[7] Tambah ke Message List");
    messages.add(tempMessage);

    debugPrint("[8] Rebuild Message");
    rebuildGroupedMessages();

    debugPrint("[9] Scroll ke bawah");
    scrollLastMessage();

    try {
      debugPrint("[10] Mulai upload/kirim API...");

      final res = await Api.sendMessage(
        conversationId: conversationId,
        message: message,
        messageType: messageType,
        file: file,
        duration: duration,
      );

      debugPrint("[11] API Response");
      debugPrint("Status Code : ${res.statusCode}");
      debugPrint("Body        : ${res.stream}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        debugPrint("✅ Berhasil kirim");
      } else {
        debugPrint("❌ Gagal kirim");

        final index = localMessages.indexWhere((e) => e["temp_id"] == tempId);

        if (index != -1) {
          localMessages[index]["status"] = "failed";

          localMessages.refresh();

          rebuildGroupedMessages();
        }
      }
    } catch (e, stack) {
      debugPrint("========== ERROR SEND ==========");
      debugPrint(e.toString());
      debugPrint(stack.toString());

      final index = localMessages.indexWhere((e) => e["temp_id"] == tempId);

      if (index != -1) {
        localMessages[index]["status"] = "failed";

        localMessages.refresh();

        rebuildGroupedMessages();
      }
    }

    debugPrint("========== END SEND ==========");
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

  void startCall({
    String? conversationID,
    String? receiverID,
    String? type,
    String? imageRechiver,
    String? nameRechiver,
  }) async {
    if (isStartCall.value) return;
    try {
      isStartCall.value = true;

      final body = {
        "conversation_id": conversationID,
        "receiver_id": receiverID,
        "type": type,
      };

      print(body);

      final res = await Api.startCallUrl(body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final response = jsonDecode(res.body);

        final data = response["data"];
        listenCallStatus(data["id"].toString());

        Get.toNamed(
          Routes.CALL_DETAIL_SCREEN,
          arguments: {
            ...data,
            "isCaller": true,
            "imageRechiver": imageRechiver,
            "nameRechiver": nameRechiver,
            "type": type,
          },
        );
        print("BERHSAIL $type CALL");
        print("RESPONSE BERHASIL BODY CALL : ${res.body}");
      } else {
        print("RESPONSE GAGAL BODY CALL : ${res.body}");
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    } finally {
      isStartCall.value = false;
    }
  }

  void listenCallStatus(String callId) {
    callStatusSub?.cancel();

    callStatusSub = FirebaseDatabase.instance
        .ref("calls")
        .child(callId)
        .onValue
        .listen((event) async {
          if (event.snapshot.value == null) return;

          final data = Map<String, dynamic>.from(event.snapshot.value as Map);

          print("CALL STATUS => ${data["status"]}");

          // HAPUS bagian join room dari sini
          // Join room sekarang dihandle oleh CallDetailScreenController
          if (data["status"] == "accepted") {
            callStatus.value = "accepted";
            // ← tidak ada ZegoCallService di sini
          }

          if (data["status"] == "ended") {
            FlutterRingtonePlayer().stop();

            // Hanya back jika masih di chat screen, bukan call screen
            // Call screen punya listener sendiri untuk back
            callStatusSub?.cancel();
          }
        });
  }

  Future<void> startVoiceRecord() async {
    isShowVoiceWave.value = true;

    await startRecord();
  }

  ///Start Record
  Future<void> startRecord() async {
    final permission = await Permission.microphone.request();

    if (!permission.isGranted) {
      Get.snackbar("Error", "Microphone permission denied");
      return;
    }

    final dir = await getTemporaryDirectory();

    final path = "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a";

    recordPath.value = path;

    recorderController.reset();

    await recorderController.record(
      path: path,
      recorderSettings: RecorderSettings(
        androidEncoderSettings: AndroidEncoderSettings(
          androidEncoder: AndroidEncoder.wav,
        ),
        iosEncoderSettings: IosEncoderSetting(
          iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
        ),
        sampleRate: 44100,
        bitRate: 128000,
      ),
    );

    duration.value = 0;

    isRecording.value = true;
    isShowVoiceWave.value = true;

    recordTimer?.cancel();

    recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      duration.value++;
    });
  }

  ///Stop Record
  Future<String?> stopRecord() async {
    recordTimer?.cancel();

    isRecording.value = false;

    final path = await recorderController.stop();

    return path;
  }

  //Cancel Record
  Future<void> cancelRecord() async {
    recordTimer?.cancel();

    isRecording.value = false;

    final path = await recorderController.stop();

    isShowVoiceWave.value = false;

    if (path != null) {
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
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
    recorderController.dispose();

    recordTimer?.cancel();
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
