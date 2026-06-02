import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/routes/app_pages.dart';
import 'package:wive_app/app/utils/api.dart';

import '../../../../utils/colors.dart';
import '../controllers/chat_screen_search_user_screen_controller.dart';

class ChatScreenSearchUserScreenView
    extends GetView<ChatScreenSearchUserScreenController> {
  const ChatScreenSearchUserScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "New Chat",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/search.png",
                      width: 24,
                      height: 24,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller.searchController,
                        minLines: 1,
                        cursorColor: AppColors.blueColor,
                        cursorHeight: 20,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recent",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(() {
                        return Column(
                          children: List.generate(controller.recentChats.length, (
                            index,
                          ) {
                            final data = controller.recentChats[index];
                            final myId = controller.userProfile.id.value;
                            final participant = data['participants'] as List;

                            final otherUser = participant.firstWhere(
                              (user) => user['id'] != myId,
                              orElse: () => null,
                            );
                            return GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.CHAT_DETAIL_SCREEN);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 48,
                                      width: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            otherUser['photo'] == null
                                                ? "https://ui-avatars.com/api/?name=${Uri.encodeComponent(otherUser['name'])}&background=E5E7EB&color=374151&size=256"
                                                : "${Api.publicUrl}storage/${otherUser['photo']}",
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${otherUser['name']}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          otherUser['username'] != null
                                              ? "@${otherUser['username']}"
                                              : "${otherUser['email']}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                      const SizedBox(height: 6),
                      Text(
                        "Results",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(() {
                        return Column(
                          children: List.generate(controller.searchResults.length, (
                            index,
                          ) {
                            final data = controller.searchResults[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          data['photo'] == null
                                              ? "https://ui-avatars.com/api/?name=${Uri.encodeComponent(data['name'])}&background=E5E7EB&color=374151&size=256"
                                              : "${Api.publicUrl}storage/${data['photo']}",
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${data['name']}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        data['username'] != null
                                            ? "@${data['username']}"
                                            : "${data['email']}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Obx(
                                    () => GestureDetector(
                                      onTap: controller.isLoadingAddUser.value
                                          ? null
                                          : () async {
                                              await controller.postConvercation(
                                                context,
                                                data['id'],
                                              );
                                            },
                                      child: SizedBox(
                                        child: Image.asset(
                                          "assets/images/iconAdd.png",
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        );
                      }),
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
