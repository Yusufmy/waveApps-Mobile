import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wive_app/app/common/get.dart';

import '../../../routes/app_pages.dart';
import '../../../service/profile_core_service.dart';
import '../../../utils/api.dart';
import '../../../utils/widgets/alert_global_widget.dart';
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

  final DatabaseReference db = FirebaseDatabase.instance.ref();

  RxList<Map<String, dynamic>> listRoomChat = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filterListRoomChat =
      <Map<String, dynamic>>[].obs;

  RxBool isLoading = false.obs;
  RxInt idUserLogin = 0.obs;
  RxInt totalUnreadMessage = 0.obs;

  StreamSubscription? roomsSub;

  ///CALL
  final DatabaseReference callRef = FirebaseDatabase.instance.ref("calls");

  ///STORY USER
  RxList listStoryUser = [].obs;
  RxBool isLoadingStory = false.obs;

  ///MY SRTORY
  RxBool isLoadingMyStory = false.obs;
  RxBool isLoadingAddStory = false.obs;
  RxBool isHasStory = false.obs;
  TextEditingController captionHistory = TextEditingController();
  final DatabaseReference storyRef = FirebaseDatabase.instance.ref(
    "story_users",
  );
  RxMap<int, bool> storyStatus = <int, bool>{}.obs;

  ///PICK IMAGE
  final ImagePicker picker = ImagePicker();
  Rx<File?> selectedImage = Rx<File?>(null);
  RxString imagePicker = "".obs;
  RxBool isPickingImage = false.obs;

  //Search
  TextEditingController searchController = TextEditingController();
  RxString searchText = "".obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchRoomChat(searchController.text);
      searchText.value = searchController.text;
      searchRoomChat(searchController.text);
    });
    initData();
  }

  Future<void> initData() async {
    idUserLogin.value = await getId() ?? 0;

    listenRooms();
    listenIncomingCall();
    listenStoryUser();
    getListStoryUser();
    getMyStory();
    updateData();
  }

  void updateData() async {
    idUserLogin.value = await getId() ?? 0;
  }

  /// =========================
  /// LISTEN ALL ROOMS REALTIME
  /// =========================
  void listenRooms() async {
    isLoading.value = true;

    final userId = await getId();

    print("USER ID LOGIN : $userId");

    roomsSub?.cancel();

    roomsSub = db.child('rooms').onValue.listen((event) {
      try {
        final data = event.snapshot.value;

        print("🔥 RAW DATA: $data");

        if (data == null || data is! Map) {
          listRoomChat.clear();
          isLoading.value = false;
          return;
        }

        final Map rawRooms = Map<String, dynamic>.from(data);

        final List<Map<String, dynamic>> rooms = [];

        rawRooms.forEach((roomKey, value) {
          if (value == null) return;

          final room = Map<String, dynamic>.from(value);

          /// META
          final meta = Map<String, dynamic>.from(room['meta'] ?? {});

          /// PARTICIPANTS
          final participantsRaw = room['participants'];

          List participants = [];

          if (participantsRaw is Map) {
            participants = participantsRaw.values.toList();
          } else if (participantsRaw is List) {
            participants = List.from(participantsRaw);
          }

          participants = participants.where((e) => e != null).toList();

          print("ROOM $roomKey PARTICIPANTS => $participants");

          /// CEK MEMBER
          final isMember = participants.any((user) {
            if (user == null) return false;

            final id = user['user_id'] ?? user['id'];

            final result = id.toString() == userId.toString();

            print(
              "CHECK USER = '$id' (${id.runtimeType}) | "
              "LOGIN = '$userId' (${userId.runtimeType}) | "
              "RESULT = $result",
            );

            return result;
          });

          print("ROOM $roomKey IS MEMBER => $isMember");

          if (!isMember) return;

          /// creator room
          final isCreator = meta['created_by'].toString() == userId.toString();

          /// apakah sudah ada pesan
          final hasMessage = (meta['last_message'] ?? '')
              .toString()
              .trim()
              .isNotEmpty;

          print(
            "ROOM $roomKey => "
            "CREATOR=$isCreator | "
            "HAS_MESSAGE=$hasMessage",
          );

          /// jika bukan creator DAN belum ada pesan
          /// jangan tampilkan room
          ///
          if (!isCreator && !hasMessage) {
            print(
              "ROOM $roomKey HIDDEN "
              "(not creator & no message)",
            );
            return;
          }

          rooms.add({
            'id': meta['id'],
            'type': meta['type'],
            'created_by': meta['created_by'],
            'created_at': meta['created_at'],
            'last_message': meta['last_message'],
            'last_message_at': meta['last_message_at'],
            'participants': participants,
          });
        });

        rooms.sort((a, b) {
          final aTime = a['last_message_at']?.toString() ?? '';

          final bTime = b['last_message_at']?.toString() ?? '';

          return bTime.compareTo(aTime);
        });

        listRoomChat.value = rooms;
        calculateUnreadMessage();

        print("✅ ROOM COUNT: ${rooms.length}");

        isLoading.value = false;
      } catch (e, s) {
        print("❌ ROOM ERROR : $e");
        print(s);

        isLoading.value = false;
      }
    });
  }

  /// =========================
  /// UPDATE ROOM AFTER MESSAGE
  /// =========================
  void updateRoomAfterMessage({
    required int roomId,
    required String message,
    required int timestamp,
  }) {
    print("ROOM ID : $roomId");
    final index = listRoomChat.indexWhere((e) => e['id'] == roomId);
    print("index : $index");

    if (index == -1) return;

    listRoomChat[index]['last_message'] = message;
    listRoomChat[index]['last_message_at'] =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toIso8601String();

    final updated = listRoomChat[index];

    listRoomChat.removeAt(index);
    listRoomChat.insert(0, updated);

    listRoomChat.refresh();
  }

  void readMessage(var conversationId) async {
    try {
      final res = await Api.readMessage(conversationId);

      if (res.statusCode == 200) {
        print("Reponse Berhisil read : ${res.body}");
      } else {
        print("Reponse Gagal read : ${res.body}");
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    }
  }

  ///CALL IN
  void listenIncomingCall() {
    // Ambil timestamp sekarang sebelum listen
    // agar hanya terima call BARU setelah app berjalan
    final listenStartTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    callRef.onChildAdded.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      // Filter: hanya untuk user ini
      if (data["receiver_id"].toString() != idUserLogin.value.toString()) {
        return;
      }

      // Filter: hanya status ringing
      if (data["status"] != "ringing") {
        return;
      }

      // Filter: hanya call yang dibuat SETELAH app listen
      // Ini mencegah call lama dari Firebase ter-trigger
      final createdAt = data["created_at"];
      if (createdAt != null && createdAt < listenStartTime) {
        print(
          "SKIP call lama: created_at=$createdAt < listenStart=$listenStartTime",
        );
        return;
      }

      showIncomingCall(data);
    });
  }

  void showIncomingCall(Map<String, dynamic> data) {
    print("INCOMING CALL DATA: $data");
    print("room_id yang akan dipakai: ${data["room_id"]}");

    FlutterRingtonePlayer().play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.glass,
      looping: true,
      volume: 1.0,
      asAlarm: false,
    );

    // Tambahkan isCaller: false agar CallDetailScreenController tahu
    Get.toNamed(
      Routes.CALL_DETAIL_SCREEN,
      arguments: {
        ...data,
        "isCaller": false, // ← tambahkan ini
      },
    );
  }

  void listenStoryUser() {
    print("LISTEN STORY START");

    storyRef.onChildChanged.listen((event) {
      print("🔥 CHILD CHANGED");

      print(event.snapshot.key);
      print(event.snapshot.value);
    });

    storyRef.onChildAdded.listen((event) {
      print("🟢 CHILD ADDED");

      print(event.snapshot.key);
      print(event.snapshot.value);
    });

    storyRef.onValue.listen((event) {
      print("🔵 VALUE CHANGED");
      getListStoryUser();
      print(event.snapshot.value);
    });
  }

  void getListStoryUser() async {
    try {
      isLoadingStory.value = true;

      final res = await Api.getListStory();
      final resJson = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final List data = resJson['data'];
        listStoryUser.assignAll(data);
        // Mapping user_id -> has_story
        storyStatus.clear();

        for (final item in data) {
          final stories = item["stories"] as List? ?? [];

          storyStatus[item["user"]["id"]] = stories.isNotEmpty;
        }
        print("LIST STATUS STORY : ${storyStatus.toJson()}");
      } else {
        print("print Gagal menampilkan sotry");
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    } finally {
      isLoadingStory.value = false;
    }
  }

  void getMyStory() async {
    try {
      isLoadingMyStory.value = true;

      final res = await Api.getMeStory();
      final resJson = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        isHasStory.value = resJson['has_story'] ?? false;
        print("Status story : ${resJson['has_story']}");
        print("RES JSON : ${resJson}");
        print("RES BODYNYA : ${res.body}");
      } else {
        print("Gagal mengambil data : ${res.body}");
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    } finally {
      isLoadingMyStory.value = false;
    }
  }

  Future<void> openGalery() async {
    if (isPickingImage.value) return;

    try {
      isPickingImage.value = true;

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      selectedImage.value = File(image.path);
      imagePicker.value = image.path;

      Get.toNamed(Routes.ADD_STORY_SCREEN);
    } catch (e) {
      print("PICK IMAGE ERROR : $e");
    } finally {
      isPickingImage.value = false;
    }
  }

  Future<void> addStory(BuildContext context) async {
    if (isLoadingAddStory.value) return;

    final file = selectedImage.value;

    if (file == null) {
      showAlert(
        context,
        text: "Pilih gambar terlebih dahulu",
        isSuccess: false,
      );
      return;
    }

    try {
      isLoadingAddStory.value = true;

      final response = await Api.postStory(
        file: file,
        caption: captionHistory.text,
      );

      final body = await response.stream.bytesToString();

      print(body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        selectedImage.value = null;
        captionHistory.clear();
        getMyStory();
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
        Get.back();

        showAlert(context, text: "Story berhasil ditambahkan", isSuccess: true);
      }
    } catch (e) {
      showAlert(context, text: "Terjadi kesalahan", isSuccess: false);
      print("Terjadi kesalahan : $e");
    } finally {
      isLoadingAddStory.value = false;
    }
  }

  void calculateUnreadMessage() {
    int total = 0;

    for (final room in listRoomChat) {
      final participantsRaw = room['participants'];

      if (participantsRaw is! List) continue;

      for (final item in participantsRaw) {
        if (item is! Map) continue;

        final participant = Map<String, dynamic>.from(item);

        final id = participant['user_id'] ?? participant['id'];

        if (id.toString() == idUserLogin.value.toString()) {
          total += (participant['unread_count'] ?? 0) as int;
          break;
        }
      }
    }

    totalUnreadMessage.value = total;
  }

  void searchRoomChat(String keyword) {
    keyword = keyword.trim().toLowerCase();

    if (keyword.isEmpty) {
      filterListRoomChat.assignAll(listRoomChat);
      return;
    }

    final result = listRoomChat.where((room) {
      final List participants = List.from(room['participants'] ?? []);

      final otherUser = participants.firstWhere((u) {
        if (u == null) return false;

        final id = u['user_id'] ?? u['id'];

        return id.toString() != idUserLogin.value.toString();
      }, orElse: () => null);

      if (otherUser == null) return false;

      final name = (otherUser['name'] ?? "").toString().toLowerCase();
      final lastMessage = (room['last_message'] ?? "").toString().toLowerCase();

      return name.contains(keyword) || lastMessage.contains(keyword);
    }).toList();

    filterListRoomChat.assignAll(result);
  }

  void clearSearch() {
    searchController.clear();
    filterListRoomChat.assignAll(listRoomChat);
  }

  @override
  void onClose() {
    roomsSub?.cancel();
    super.onClose();
  }
}
