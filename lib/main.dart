import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:wive_app/app/service/firebase_core_service.dart';

import 'app/routes/app_pages.dart';
import 'app/service/profile_core_service.dart';

import 'app/utils/colors.dart';

import 'package:permission_handler/permission_handler.dart';

Future<void> requestCallPermissions() async {
  await [
    Permission.microphone,
    Permission.camera, // opsional untuk video call nanti
  ].request();
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await requestCallPermissions(); // ← tambahkan ini
  Get.put(ProfileCoreService());

  final firebaseCore = Get.put(FirebaseCoreService());

  await firebaseCore.initFCM();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Android
      statusBarBrightness: Brightness.light, // iOS
    ),
  );

  runApp(
    GetMaterialApp(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.blueColor,
          selectionColor: AppColors.blueColor.withOpacity(0.3),
          selectionHandleColor: AppColors.blueColor,
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
