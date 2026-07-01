import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/routes/app_pages.dart';
import 'package:wive_app/app/utils/api.dart';
import 'package:wive_app/app/utils/colors.dart';

import '../../../utils/format.dart';
import '../../../utils/widgets/alert_global_widget.dart';
import '../controllers/chat_screen_controller.dart';

class ChatScreenView extends GetView<ChatScreenController> {
  const ChatScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: AppColors.blueColor,
          color: Colors.white,
          onRefresh: () async {
            controller.getListStoryUser();
            controller.listenRooms();
          },
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
                            image: controller.userProfile.isLoading.value
                                ? null
                                : DecorationImage(
                                    image: NetworkImage(
                                      controller.userProfile.photo.value.isEmpty
                                          ? "https://ui-avatars.com/api/?name=${Uri.encodeComponent(controller.userProfile.name.value)}&background=E5E7EB&color=374151&size=256"
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
                          Obx(
                            () => Text(
                              "${controller.totalUnreadMessage.value}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: 40,
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              alertSearch(
                                context,
                                controller.searchController,
                                onChanged: controller.searchRoomChat,
                                onClose: controller.clearSearch,
                              );
                            },
                            child: Image.asset(
                              "assets/images/search.png",
                              width: 24,
                              height: 24,
                              color: Colors.black54,
                            ),
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
                      Obx(
                        () => SizedBox(
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  if (controller.isHasStory.value == true) ...[
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.blueColor,
                                      ),
                                    ),
                                  ],
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (controller.isHasStory.value == true) {
                                        Get.toNamed(
                                          Routes.STORY_VIEW_SCREEN,
                                          arguments: {
                                            "idStory":
                                                "${controller.idUserLogin.value}",
                                            "idUserLogin":
                                                "${controller.idUserLogin.value}",
                                          },
                                        );
                                      } else {
                                        return;
                                      }
                                    },
                                    child: Container(
                                      height: 48,
                                      width: 48,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            controller
                                                        .userProfile
                                                        .photo
                                                        .value
                                                        .isEmpty ||
                                                    controller
                                                            .userProfile
                                                            .photo
                                                            .value ==
                                                        "null"
                                                ? "https://ui-avatars.com/api/?name=${Uri.encodeComponent("${controller.userProfile.name}")}&background=E5E7EB&color=374151&size=256"
                                                : "${Api.publicUrl}storage/${controller.userProfile.photo.value}",
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -8,
                                    left: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: controller.isPickingImage.value
                                          ? null
                                          : () {
                                              controller.openGalery();
                                            },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 12,
                                              offset: Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.add,
                                            color: AppColors.blueColor,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "You",
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
                      const SizedBox(width: 12),
                      Obx(() {
                        return Row(
                          children: List.generate(
                            controller.listStoryUser.length,
                            (index) {
                              final data = controller.listStoryUser[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed(
                                      Routes.STORY_VIEW_SCREEN,
                                      arguments: {
                                        "idStory": "${data["user"]["id"]}",
                                        "idUserLogin":
                                            "${controller.idUserLogin.value}",
                                      },
                                    );
                                  },
                                  child: buildProfile(
                                    title: "${data['user']['name']}",
                                    image: "${data["user"]["photo"]}",
                                    isStory: true,
                                  ),
                                ),
                              );
                            },
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
                  child: Obx(() {
                    final room = controller.searchText.value.isEmpty
                        ? controller.listRoomChat
                        : controller.filterListRoomChat;
                    return Column(
                      children: List.generate(room.length, (index) {
                        final data = room[index];
                        final userId = controller.idUserLogin.value;

                        final List participants = List.from(
                          data['participants'] ?? [],
                        );

                        final otherUser = participants.firstWhere((u) {
                          if (u == null) return false;

                          final id = u['user_id'] ?? u['id'];

                          return id.toString() != userId.toString();
                        }, orElse: () => null);

                        final isMember = participants.any((user) {
                          if (user == null) return false;

                          final id = user['user_id'] ?? user['id'];

                          return id.toString() == userId.toString();
                        });

                        if (!isMember || otherUser == null) {
                          return const SizedBox.shrink();
                        }

                        final myParticipant = participants.firstWhere((u) {
                          if (u == null) return false;

                          final id = u['user_id'] ?? u['id'];

                          return id.toString() == userId.toString();
                        }, orElse: () => null);

                        final hasStory =
                            controller.storyStatus[otherUser["user_id"]] ??
                            false;

                        final unreadCount = myParticipant?['unread_count'] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(
                                      Routes.STORY_VIEW_SCREEN,
                                      arguments: {
                                        "idStory": "${otherUser?['user_id']}",
                                        "idUserLogin":
                                            "${controller.idUserLogin.value}",
                                      },
                                    );
                                  },
                                  child: buildProfile(
                                    image: "${otherUser?['photo']}",
                                    title: "${otherUser?['name']}",
                                    isStory: false,
                                    showStory: hasStory,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      print("DATA ID ROOM : ${data['id']}");
                                      controller.readMessage("${data['id']}");
                                      Get.toNamed(
                                        Routes.CHAT_DETAIL_SCREEN,
                                        arguments: {
                                          "conversationId": "${data['id']}",
                                          "name": "${otherUser?['name']}",
                                          "photo": "${otherUser?['photo']}",
                                          "idUserRechiver":
                                              "${otherUser?['user_id']}",
                                        },
                                      )?.then((_) {
                                        controller.readMessage("${data['id']}");
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${otherUser?['name']}",
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  "${data['last_message'] ?? ""}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: AppColors
                                                        .textGreeyColor,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            children: [
                                              Text(
                                                formatHour(
                                                  data['last_message_at'],
                                                ),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textGreeyColor,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              if (unreadCount != 0) ...[
                                                Container(
                                                  padding: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red,
                                                  ),
                                                  child: Text(
                                                    "$unreadCount",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ],
            ),
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

  Widget buildProfile({
    String? title,
    String? image,
    bool? isStory,
    bool? showStory,
  }) {
    return SizedBox(
      width: isStory == true ? 80 : null,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (showStory == true || isStory == true) ...[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blueColor,
                  ),
                ),
              ],
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
                    image: NetworkImage(
                      image == null || image.isEmpty || image == "null"
                          ? "https://ui-avatars.com/api/?name=${Uri.encodeComponent(title ?? "")}&background=E5E7EB&color=374151&size=256"
                          : "${Api.publicUrl}storage/$image",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          if (isStory == true) ...[
            const SizedBox(height: 6),
            Text(
              "$title",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textGreeyColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
