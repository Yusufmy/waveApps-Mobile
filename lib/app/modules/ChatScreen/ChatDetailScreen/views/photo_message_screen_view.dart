import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/modules/ChatScreen/ChatDetailScreen/controllers/chat_screen_chat_detail_screen_controller.dart';
import 'package:wive_app/app/utils/colors.dart';

class PhotoMessageScreenView
    extends GetView<ChatScreenChatDetailScreenController> {
  final String imagePath;
  final String conversionId;
  const PhotoMessageScreenView({
    super.key,
    required this.imagePath,
    required this.conversionId,
  });
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        // Status Bar
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,

        // Navigation Bar
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light, // Android
            statusBarBrightness: Brightness.light, // iOS
            // Navigation Bar
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarDividerColor: Colors.white,
          ),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.borderGreeyColor,
                    ),
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    SystemChrome.setSystemUIOverlayStyle(
                      const SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent,
                        statusBarIconBrightness: Brightness.light, // Android
                        statusBarBrightness: Brightness.light, // iOS
                        // Navigation Bar
                        systemNavigationBarColor: Colors.white,
                        systemNavigationBarIconBrightness: Brightness.dark,
                        systemNavigationBarDividerColor: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.borderGreeyColor,
                    borderRadius: BorderRadius.circular(48),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.messageController,
                          focusNode: controller.messageFocus,
                          cursorColor: AppColors.blueColor,
                          cursorHeight: 20,
                          onTap: () {
                            controller.isEmojiVisible.value = false;
                          },

                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: "Type message",
                            hintStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await controller.sendMessage(
                            context: context,
                            conversationId: controller.conversationId.value,
                            messageType: "image",
                            file: File(imagePath),
                            message: controller.messageController.text.trim(),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.blueColor,
                          ),
                          child: Center(
                            child: Image.asset(
                              "assets/images/send.png",
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
