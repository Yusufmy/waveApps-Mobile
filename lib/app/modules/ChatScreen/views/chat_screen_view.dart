import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/routes/app_pages.dart';
import 'package:wive_app/app/utils/api.dart';
import 'package:wive_app/app/utils/colors.dart';

import '../controllers/chat_screen_controller.dart';

class ChatScreenView extends GetView<ChatScreenController> {
  const ChatScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 12, bottom: 66),
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Inbox",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Obx(
                      () => Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                              controller.userProfile.photo.value.isEmpty
                                  ? "https://ui-avatars.com/api/?name=${controller.userProfile.name.value}&background=random&color=fff"
                                  : "${Api.publicUrl}storage/${controller.userProfile.photo.value}",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "23",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 40,
                          ),
                        ),
                        const Spacer(),
                        Image.asset(
                          "assets/images/search.png",
                          width: 24,
                          height: 24,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.SEARCH_USER_SCREEN);
                          },
                          child: Image.asset(
                            "assets/images/iconAdd.png",
                            width: 24,
                            height: 24,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Undread message",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textGreeyColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "View Stories",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(
                      child: Column(
                        children: [
                          buildButtonAddStory(),
                          const SizedBox(height: 6),
                          Text(
                            "Add Story",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textGreeyColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ...List.generate(10, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: buildProfile(
                          title: "Alex",
                          image: "assets/images/profile.jpg",
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Recent Chats",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.CHAT_DETAIL_SCREEN);
                        },
                        child: Container(
                          decoration: BoxDecoration(color: Colors.transparent),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              buildProfile(image: "assets/images/profile.jpg"),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Alexander",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Send me the files....",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textGreeyColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                "12.00",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textGreeyColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButtonAddStory() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.borderGreeyColor,
          ),
        ),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
        Container(
          height: 48,
          width: 48,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            // border: Border.all(color: Colors.black26, width: 1),
            shape: BoxShape.circle,
          ),
          child: Center(child: Image.asset("assets/images/iconAdd.png")),
        ),
      ],
    );
  }

  Widget buildProfile({String? title, String? image}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blueColor,
              ),
            ),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            Container(
              height: 48,
              width: 48,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage("$image"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        if (title != null) ...[
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textGreeyColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
