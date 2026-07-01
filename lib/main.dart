import 'dart:ui';

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

  // Tangkap semua FlutterError (termasuk dari PlatformException async yang lolos)
  FlutterError.onError = (FlutterErrorDetails details) {
    final isWaveformStopError =
        details.exception is PlatformException &&
        (details.exception as PlatformException).stacktrace?.contains(
              'WaveformExtractor.stop',
            ) ==
            true;

    if (isWaveformStopError) {
      debugPrint(
        "⚠️ Diabaikan: race condition internal audio_waveforms saat stop extractor. "
        "Ini bug plugin, tidak mempengaruhi fungsi app.",
      );
      return; // jangan propagate, jangan crash
    }

    FlutterError.presentError(details);
  };

  // Tangkap juga yang lolos dari native platform channel / zone lain
  PlatformDispatcher.instance.onError = (error, stack) {
    if (error is PlatformException &&
        error.stacktrace?.contains('WaveformExtractor.stop') == true) {
      debugPrint("⚠️ Diabaikan (PlatformDispatcher): $error");
      return true; // true = sudah ditangani, jangan crash
    }
    debugPrint("🔥 Uncaught error: $error");
    debugPrint("   stack: $stack");
    return true;
  };

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
