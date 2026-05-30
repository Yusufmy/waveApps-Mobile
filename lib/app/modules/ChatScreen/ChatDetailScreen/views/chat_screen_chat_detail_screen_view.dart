import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/routes/app_pages.dart';
import 'package:wive_app/app/utils/colors.dart';

import '../controllers/chat_screen_chat_detail_screen_controller.dart';

class ChatScreenChatDetailScreenView
    extends GetView<ChatScreenChatDetailScreenController> {
  const ChatScreenChatDetailScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 100,
                padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
                decoration: BoxDecoration(color: AppColors.blueColor),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: SizedBox(
                        child: Image.asset(
                          "assets/images/arrow_back_white.png",
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage("assets/images/profile.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Alexander",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Online",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.CALL_DETAIL_SCREEN),
                      child: SizedBox(
                        child: Image.asset(
                          "assets/images/voiceCall.png",
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.CALL_DETAIL_SCREEN),
                      child: SizedBox(
                        child: Image.asset(
                          "assets/images/videoCall.png",
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Sunday, 22 May 2026",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGreeyColor,
                ),
              ),
              const SizedBox(height: 16),
              buildBubbleChat(isMe: true, message: "Hello, Good Morning"),
              const SizedBox(height: 16),
              buildBubbleChat(isMe: false, message: "Hello, Good Morning too"),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: buildInputMessage(),
          ),
        ],
      ),
    );
  }

  Widget buildBubbleChat({bool isMe = false, required String message}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: EdgeInsets.only(
            left: isMe ? 160 : 16,
            right: isMe ? 16 : 160,
          ),
          decoration: BoxDecoration(
            color: isMe ? AppColors.blueColor : Colors.grey.shade300,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isMe ? Colors.white : Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "14:00",
                    style: GoogleFonts.poppins(
                      color: isMe ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (isMe == true) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.check, color: Colors.white, size: 14),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputMessage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.borderGreeyColor,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blueFieldColor,
            ),
            child: Center(
              child: Image.asset(
                "assets/images/emoji.png",
                width: 20,
                height: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: TextFormField(
              // controller: textEditingController,
              cursorColor: AppColors.blueColor,
              cursorHeight: 20,
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
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blueFieldColor,
            ),
            child: Center(
              child: Image.asset(
                "assets/images/mic.png",
                width: 20,
                height: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blueFieldColor,
            ),
            child: Center(
              child: Image.asset(
                "assets/images/send.png",
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
