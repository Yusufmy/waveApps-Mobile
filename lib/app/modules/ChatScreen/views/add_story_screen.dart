import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wive_app/app/utils/colors.dart';

import '../../../utils/widgets/input_global_widget.dart';
import '../controllers/chat_screen_controller.dart';

class AddStoryScreen extends GetView {
  const AddStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ChatScreenController controller = Get.find<ChatScreenController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 16,
                    child: GestureDetector(
                      onTap: () {
                        controller.selectedImage.value = null;
                        controller.imagePicker.value = "";
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.borderGreeyColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.black),
                      ),
                    ),
                  ),
                  Center(
                    child: Obx(() {
                      final file = controller.selectedImage.value;

                      if (file == null || !file.existsSync()) {
                        return const SizedBox();
                      }

                      return Image.file(file);
                    }),
                  ),
                  Positioned(
                    bottom: 28,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Expanded(
                          child: buildInputGlobalWidget(
                            context,
                            hintText: "Caption",
                            textEditingController: controller.captionHistory,
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () async {
                            await controller.addStory(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.blueColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
