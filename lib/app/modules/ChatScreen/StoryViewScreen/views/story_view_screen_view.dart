import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/utils/api.dart';
import 'package:wive_app/app/utils/colors.dart';

import '../controllers/story_screen_controller.dart';

class ChatScreenStoryViewScreenView extends GetView<StoryScreenController> {
  const ChatScreenStoryViewScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (controller.listStory.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.blueColor),
            );
          }

          final story = controller.listStory[controller.currentIndex.value];

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final width = MediaQuery.of(context).size.width;
              final dx = details.globalPosition.dx;

              // kiri
              if (dx < width * 0.3) {
                controller.previousStory();
              }
              // kanan
              else if (dx > width * 0.7) {
                controller.nextStory();
              }
              // tengah
              else {
                controller.togglePause();
              }
            },

            child: Stack(
              children: [
                /// STORY IMAGE
                Positioned.fill(
                  child: Image.network(story["media_url"], fit: BoxFit.contain),
                ),

                /// DARK OVERLAY
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.2)),
                ),

                Obx(() {
                  if (!controller.showActionIcon.value) {
                    return const SizedBox();
                  }

                  return Center(
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: 1,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          controller.actionIcon.value,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  );
                }),

                /// TOP CONTENT
                SafeArea(
                  child: Column(
                    children: [
                      /// PROGRESS BAR
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          children: List.generate(controller.listStory.length, (
                            index,
                          ) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                height: 1,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Obx(() {
                                  double value = 0;

                                  if (index < controller.currentIndex.value) {
                                    value = 1;
                                  } else if (index ==
                                      controller.currentIndex.value) {
                                    value = controller.progress.value;
                                  }

                                  return FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// HEADER
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(width: 16),

                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                "${Api.publicUrl}storage/${story["user"]["photo"]}",
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                story['user']['name'] ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if ("${story['user_id']}" ==
                                controller.idUserLogin.value) ...[
                              PopupMenuButton<String>(
                                color: Colors.white,
                                icon: const Icon(
                                  Icons.more_horiz_outlined,
                                  color: Colors.white,
                                ),
                                onSelected: (value) {
                                  controller.deleteStory("${story['id']}");
                                  // if (value == 'delete') {
                                  //   controller.deleteStory();
                                  // }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Hapus Story",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                /// CAPTION
                if ((story["caption"] ?? "").toString().isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 50,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.black26),
                      child: Text(
                        story["caption"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
