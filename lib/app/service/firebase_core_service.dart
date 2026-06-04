import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:wive_app/app/common/get.dart';

import '../common/store.dart';

class FirebaseCoreService extends GetxService with WidgetsBindingObserver {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  RxString fcmToken = ''.obs;

  DatabaseReference? _presenceRef;

  Future<void> initFCM() async {
    WidgetsBinding.instance.addObserver(this);

    await _messaging.requestPermission();

    final token = await _messaging.getToken();

    if (token != null) {
      fcmToken.value = token;

      await storeTokenFCM(token);

      print("FCM TOKEN: $token");
    }

    _messaging.onTokenRefresh.listen((newToken) {
      fcmToken.value = newToken;

      print("FCM TOKEN REFRESH: $newToken");
    });

    await initPresence();
  }

  Future<void> initPresence() async {
    final userId = await getId();

    print("🔥 PRESENCE USER ID = $userId");

    if (userId == null) return;

    _presenceRef = _database.ref("presence/$userId");

    final connectedRef = _database.ref(".info/connected");

    connectedRef.onValue.listen((event) async {
      final connected = event.snapshot.value as bool? ?? false;

      if (!connected) return;

      await _presenceRef!.onDisconnect().update({
        "online": false,
        "last_seen": ServerValue.timestamp,
      });

      await _presenceRef!.update({
        "online": true,
        "last_seen": ServerValue.timestamp,
      });
    });
  }

  Future<void> setOnline() async {
    if (_presenceRef == null) return;

    await _presenceRef!.update({
      "online": true,
      "last_seen": ServerValue.timestamp,
    });
  }

  Future<void> setOffline() async {
    if (_presenceRef == null) return;

    await _presenceRef!.update({
      "online": false,
      "last_seen": ServerValue.timestamp,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        setOnline();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        setOffline();
        break;

      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
