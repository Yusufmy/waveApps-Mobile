import 'dart:convert';

import 'package:get/get.dart';
import 'package:wive_app/app/common/get.dart';
import 'package:wive_app/app/common/store.dart';
import 'package:wive_app/app/utils/api.dart';

class ProfileCoreService extends GetxController {
  RxInt id = 0.obs;
  RxString fireBaseUid = ''.obs;
  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString photo = ''.obs;
  RxString bio = ''.obs;
  RxInt isOnline = 0.obs;
  RxString lastSeen = ''.obs;
  RxString fcmToken = ''.obs;

  Future<void> getProfile() async {
    try {
      final res = await Api.getProfile();
      final resJson = jsonDecode(res.body);
      final data = resJson['user'];

      if (res.statusCode == 200 || res.statusCode == 201) {
        await storeId(data["id"] ?? "");
        await storeFirebaseUid(data["firebase_uid"] ?? "");
        await storeName(data["name"] ?? "");
        await storeEmail(data["email"] ?? "");
        await storePhotoProfile(data["photo"] ?? "");
        await storeBio(data["bio"] ?? "");
        await storeIsOnline(data["is_online"] ?? 0);
        await storeLastSeen(data["last_seen"] ?? "");
        await storeFcmToken(data["fcm_token"] ?? "");
      } else {
        print("Gagal mengambil data profile : ${res.body}");
      }
    } catch (e) {
      print("Terjadi kesalahan : $e");
    }
  }

  Future<void> getProfileLocal() async {
    id.value = await getId() ?? 0;
    fireBaseUid.value = await getFirebaseUid() ?? '';
    name.value = await getName() ?? '';
    email.value = await getEmail() ?? '';
    photo.value = await getPhotoProfile() ?? '';
    bio.value = await getBio() ?? '';
    isOnline.value = await getIsOnline() ?? 0;
    lastSeen.value = await getLastSeen() ?? '';
    fcmToken.value = await getFcmToken() ?? '';
  }

  void updateData() async {
    final token = await getToken();

    if (token != null) {
      await getProfile();
      await getProfileLocal();
    } else {
      print("Gagal megenerate");
    }
  }

  @override
  void onInit() {
    updateData();
    super.onInit();
  }
}
