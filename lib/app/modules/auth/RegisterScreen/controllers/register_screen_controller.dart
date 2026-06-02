import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:wive_app/app/routes/app_pages.dart';
import 'package:wive_app/app/utils/api.dart';

import '../../../../utils/systemChrome.dart';
import '../../../../utils/widgets/alert_global_widget.dart';

class RegisterScreenController extends GetxController {
  //TODO: Implement RegisterScreenController

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confrimPasswordController = TextEditingController();

  RxBool isRegister = false.obs;

  Future<void> register(BuildContext context) async {
    if (isRegister.value) return;

    try {
      isRegister.value = true;
      final body = {
        "name": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "confirm_password": confrimPasswordController.text,
      };

      final res = await Api.register(body);
      final resJson = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        showAlert(
          context,
          text: resJson['message'] ?? "Berhasil registrasi",
          isSuccess: true,
        );
        Get.toNamed(Routes.LOGIN_SCREEN);
      } else {
        showAlert(
          context,
          text: resJson['message'] ?? "Gagal registrasi",
          isSuccess: false,
        );
      }
    } catch (e) {
      showAlert(context, text: "Terjadi kesalahan", isSuccess: false);
      print("Terjadi kesalahan : $e");
    } finally {
      isRegister.value = false;
    }
  }

  final count = 0.obs;
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

  void increment() => count.value++;
}
