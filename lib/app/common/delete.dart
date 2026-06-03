import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wive_app/app/common/get.dart';
import 'package:wive_app/app/routes/app_pages.dart';
import 'package:wive_app/app/utils/api.dart';

import '../utils/widgets/alert_global_widget.dart';

Future<void> deleteToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
}

Future<void> deleteId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('id');
}

Future<void> deleteName() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('name');
}

Future<void> deleteUserName() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('user_name');
}

Future<void> deleteEmail() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('email');
}

Future<void> deletePhotoProfile() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('photo_profile');
}

Future<void> deleteBio() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('bio');
}

Future<void> deleteIsOnline() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('is_online');
}

Future<void> deleteLastSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('last_seen');
}

Future<void> deleteFcmToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('fcm_token');
}

Future<void> logout(BuildContext context, bool isLogout) async {
  try {
    isLogout = true;
    final res = await Api.logout();
    final resJson = jsonDecode(res.body);
    final userId = await getId();
    print(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      showAlert(
        context,
        text: resJson['message'] ?? "Berhasil Logout",
        isSuccess: true,
      );

      await FirebaseDatabase.instance.ref("presence/$userId").update({
        "online": false,
        "last_seen": ServerValue.timestamp,
      });
      await deleteToken();
      await deleteId();
      await deleteName();
      await deleteUserName();
      await deleteEmail();
      await deleteBio();
      await deleteIsOnline();
      await deleteLastSeen();

      Get.offAllNamed(Routes.LOGIN_SCREEN);
    } else {
      showAlert(
        context,
        text: resJson['error']['message'] ?? "Gagal Logout",
        isSuccess: false,
      );
    }
  } catch (e) {
    print(e);
    showAlert(context, text: "Terjadi kesalahan", isSuccess: false);
  } finally {
    isLogout = false;
  }
}
