import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wive_app/app/utils/api.dart';

import '../../../../service/profile_core_service.dart';
import '../../../../utils/widgets/alert_global_widget.dart';

class ProfileScreenChangeProfileScreenController extends GetxController {
  final userProfile = Get.find<ProfileCoreService>();

  TextEditingController changeNameController = TextEditingController();
  TextEditingController changeEmailController = TextEditingController();

  RxBool isUpdateProfile = false.obs;
  final ImagePicker picker = ImagePicker();

  Rx<File?> selectedImage = Rx<File?>(null);

  Future<void> pickImage(BuildContext context) async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    try {
      selectedImage.value = File(image.path);

      final res = await Api.uploadProfile(image.path);

      print("STATUS : ${res.statusCode}");

      final responseBody = await res.stream.bytesToString();

      print("RESPONSE : $responseBody");

      final resJson = jsonDecode(responseBody);

      if (res.statusCode == 200 || res.statusCode == 201) {
        userProfile.updateData();

        showAlert(
          context,
          text: resJson['message'] ?? "Foto profile berhasil diperbarui",
          isSuccess: true,
        );
      } else {
        showAlert(
          context,
          text: resJson['message'] ?? "Gagal upload foto profile",
          isSuccess: false,
        );
      }
    } catch (e) {
      print("ERROR UPLOAD : $e");

      showAlert(
        context,
        text: "Terjadi kesalahan saat upload foto",
        isSuccess: false,
      );
    }
  }

  void updateData() async {
    changeNameController.text = userProfile.name.value;
    changeEmailController.text = userProfile.email.value;
  }

  // Future<void> updateProfile() async {
  //   if(isUpdateProfile.value) return;
  //   try{
  //     isUpdateProfile.value = true;

  //     final body = {
  //       ""
  //     };
  //   }catch(e){
  //     print("Terjadi kesalahan : $e");
  //   } finally{
  //     isUpdateProfile.value = false;
  //   }
  // }

  final count = 0.obs;
  @override
  void onInit() {
    updateData();
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
