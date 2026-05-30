import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/utils/colors.dart';

import '../controllers/chat_screen_controller.dart';

class ChatScreenTab extends StatefulWidget {
  const ChatScreenTab({super.key});

  @override
  State<ChatScreenTab> createState() => _ChatScreenTabState();
}

class _ChatScreenTabState extends State<ChatScreenTab> {
  @override
  Widget build(BuildContext context) {
    ChatScreenController controller = Get.put(ChatScreenController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Obx(() {
              return Column(
                children: [
                  Expanded(
                    child: IndexedStack(
                      clipBehavior: Clip.none,
                      index: controller.currentPage.value,
                      children: controller.listPage,
                    ),
                  ),
                ],
              );
            }),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 12,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blueColor,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 16),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.currentPage.value = 0;
                      },
                      child: buildbuttonKlik(
                        context,
                        "assets/images/iconChat.png",
                        "Chat",
                        0,
                        controller,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.currentPage.value = 1;
                      },
                      child: buildbuttonKlik(
                        context,
                        "assets/images/iconPhone.png",
                        "Call",
                        1,
                        controller,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.currentPage.value = 2;
                      },
                      child: buildbuttonKlik(
                        context,
                        "assets/images/profile.png",
                        "Profile",
                        2,
                        controller,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildbuttonKlik(
    BuildContext context,
    String icon,
    String label,
    int index,
    ChatScreenController controller,
  ) {
    return Obx(() {
      final page = controller.currentPage.value == index;
      return SizedBox(
        child: Column(
          children: [
            Image.asset(
              icon,
              width: 24,
              height: 24,
              color: page ? Colors.white : AppColors.borderGreeyColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: page ? FontWeight.w500 : FontWeight.w400,
                fontSize: 14,
                color: page ? Colors.white : AppColors.borderGreeyColor,
              ),
            ),
          ],
        ),
      );
    });
  }
}
