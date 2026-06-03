import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:wive_app/app/common/get.dart';
import 'package:wive_app/app/utils/api.dart';

import '../../../../common/store.dart';
import '../../../../routes/app_pages.dart';
import '../../../../service/profile_core_service.dart';
import '../../../../utils/systemChrome.dart';
import '../../../../utils/widgets/alert_global_widget.dart';

class LoginScreenController extends GetxController {
  //TODO: Implement LoginScreenController

  final userProfile = Get.find<ProfileCoreService>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool isLogin = false.obs;
  RxString passwordText = ''.obs;

  Future<void> postFmc(BuildContext context) async {
    final tokenFcm = await getTokenFCM();
    try {
      final body = {"fcm_token": tokenFcm};

      final res = await Api.postFcm(body);
      final resJson = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        userProfile.updateData();
        Get.toNamed(Routes.CHAT_SCREEN);
      } else {
        showAlert(context, text: "${resJson['message']}", isSuccess: false);
      }
    } catch (e) {
      showAlert(context, text: "Terjadi kesalahan token FCM", isSuccess: false);
      print("Terjadi kesalahan: $e");
    }
  }

  Future<void> login(BuildContext context) async {
    if (isLogin.value) return;
    try {
      isLogin.value = true;

      final body = {
        "email": emailController.text,
        "password": passwordController.text,
      };

      final res = await Api.login(body);
      final resJson = jsonDecode(res.body);
      final data = resJson['user'];

      print("REQUEST BODY LOGIN : ${body}");
      print("RESPONES BODY : ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        await storeToken(resJson['access_token']);

        showAlert(
          context,
          text: "${resJson['message'] ?? "Berhasil Login"}",
          isSuccess: true,
        );
        await storeId(data["id"] ?? "");
        await storeFirebaseUid(data["firebase_uid"] ?? "");
        await FirebaseDatabase.instance.ref("presence/${data["id"]}").update({
          "online": true,
          "last_seen": ServerValue.timestamp,
        });
        await storeName(data["name"] ?? "");
        await storeEmail(data["email"] ?? "");
        await storePhotoProfile(data["photo"] ?? "");
        await storeBio(data["bio"] ?? "");
        await storeIsOnline(data["is_online"] ?? 0);
        await storeLastSeen(data["last_seen"] ?? "");
        await storeFcmToken(data["fcm_token"] ?? "");
        await postFmc(context);
      } else {
        showAlert(context, text: "${resJson['message']}", isSuccess: false);
      }
    } catch (e) {
      showAlert(context, text: "Terjadi kesalahan", isSuccess: false);
      print("Terjadi kesalahan");
    } finally {
      isLogin.value = false;
    }
  }

  @override
  void onInit() {
    SystemChromeConfig.setLightNavigationBar();
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
}
