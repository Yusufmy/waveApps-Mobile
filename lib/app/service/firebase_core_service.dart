import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../common/store.dart';

class FirebaseCoreService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  RxString fcmToken = ''.obs;

  Future<void> initFCM() async {
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
  }
}
