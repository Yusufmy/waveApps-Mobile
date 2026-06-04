import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/routes/app_pages.dart';
import 'package:wive_app/app/utils/colors.dart';

import '../../../../utils/api.dart';
import '../../../../utils/format.dart';
import '../../../../utils/runningText.dart';
import '../controllers/chat_screen_chat_detail_screen_controller.dart';

class ChatScreenChatDetailScreenView
    extends GetView<ChatScreenChatDetailScreenController> {
  const ChatScreenChatDetailScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    ChatScreenChatDetailScreenController controller = Get.put(
      ChatScreenChatDetailScreenController(),
    );
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
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 2, 38, 91),
                ),
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
                    Obx(() {
                      return Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                              controller.photo.value.isEmpty ||
                                      controller.photo.value == "null"
                                  ? "https://ui-avatars.com/api/?name=${Uri.encodeComponent(controller.name.value)}&background=E5E7EB&color=374151&size=256"
                                  : "${Api.publicUrl}storage/${controller.photo.value}",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(
                            () => Text(
                              controller.name.value,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Obx(
                            () => RunningText(
                              text: controller.statusRechiver.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
              // const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final keys = controller.groupedMessages.keys.toList();

                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.only(top: 16, bottom: 150),
                    itemCount: keys.length,
                    itemBuilder: (context, index) {
                      final dateKey = keys[index];
                      final messages = controller.groupedMessages[dateKey]!;

                      final dateText = formatChatDate(
                        messages.first['created_at'],
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 📅 DATE HEADER
                          Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Text(
                                dateText,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),

                          // 💬 MESSAGES (FLAT, NO LISTVIEW)
                          ...messages.asMap().entries.map((entry) {
                            final i = entry.key;
                            final msg = entry.value;

                            final isMe =
                                msg['sender_id'].toString() ==
                                controller.idUserLogin.value.toString();

                            bool isLastInGroup = false;

                            if (i == messages.length - 1) {
                              isLastInGroup = true;
                            } else {
                              final current = msg['created_at'] ?? 0;
                              final next = messages[i + 1]['created_at'] ?? 0;

                              if (!isSameMinuteGroup(current, next)) {
                                isLastInGroup = true;
                              }
                            }

                            return buildBubbleChat(
                              isMe: isMe,
                              message: msg['message'] ?? "",
                              time: msg['created_at'] ?? 0,
                              status: msg['status'] ?? 0,
                              showAmber: isLastInGroup && !isMe,
                            );
                          }).toList(),
                        ],
                      );
                    },
                  );
                }),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Obx(
                () =>
                    buildInputMessage(context, controller.conversationId.value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatus(String status) {
    switch (status) {
      case "sending":
        return const Icon(Icons.access_time, size: 14, color: Colors.white70);

      case "sent":
        return const Icon(Icons.check, size: 14, color: Colors.white70);

      case "delivered":
        return const Icon(Icons.done_all, size: 14, color: Colors.white70);

      case "read":
        return const Icon(Icons.done_all, size: 14, color: Colors.blue);

      default:
        return const SizedBox();
    }
  }

  Widget buildBubbleChat({
    bool isMe = false,
    required String message,
    required int time,
    required String status,
    bool showAmber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ), // 🔥 KEY FIX
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: EdgeInsets.only(left: isMe ? 0 : 14),
              constraints: BoxConstraints(
                maxWidth: Get.width * 0.7, // 🔥 WA STYLE WIDTH
              ),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color.fromARGB(255, 2, 38, 91)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formatChatTime(time),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isMe ? Colors.white70 : Colors.black45,
                        ),
                      ),
                      if (isMe == true) ...[
                        const SizedBox(width: 4),
                        // Image.asset(
                        //   "assets/images/doubleCheck.png",
                        //   width: 14,
                        //   height: 14,
                        //   color: Colors.blue,
                        // ),
                        buildStatus(status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (!isMe && showAmber) ...[
              const SizedBox(height: 4), // 🔥 kecilin jarak
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                      controller.photo.value.isEmpty ||
                              controller.photo.value == "null"
                          ? "https://ui-avatars.com/api/?name=${Uri.encodeComponent(controller.name.value)}&background=E5E7EB&color=374151&size=256"
                          : "${Api.publicUrl}storage/${controller.photo.value}",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 4), // 🔥 kecilin jarak
            ],
          ],
        ),
      ),
    );
  }

  Widget buildInputMessage(BuildContext context, String conversionId) {
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
              controller: controller.messageController,
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
          GestureDetector(
            onTap: () {
              controller.sendMessage(context, conversionId);
            },
            child: Container(
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
          ),
        ],
      ),
    );
  }
}
