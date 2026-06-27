import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/utils/api.dart';
import 'package:wive_app/app/utils/colors.dart';
// import 'package:zego_express_engine/zego_express_engine.dart';

import '../../../../../utils/call_center.dart';
import '../controllers/call_detail_screen_controller.dart';

class CallDetailScreenView extends GetView<CallDetailScreenController> {
  const CallDetailScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueColor,
      body: Obx(() {
        if (controller.typeCall.value == "video") {
          return buildVideoCall();
        }

        return buildVoiceCall();
      }),
    );
  }

  Widget buildVideoCall() {
    return Obx(() {
      // Sebelum accepted — tampilkan waiting screen
      if (controller.callStatus.value != "accepted") {
        return _buildWaitingScreen();
      }

      // Setelah accepted — tampilkan Prebuilt call
      return Stack(
        children: [
          Positioned.fill(
            child: CallPage(
              roomID: controller.callData['room_id'],
              userID: "${controller.profile.id.value}",
              userName: controller.profile.name.value,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildWaitingScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final image = controller.imageRechiver.value.isNotEmpty
                  ? controller.imageRechiver.value
                  : controller.callData["caller_photo"] == null
                  ? "https://ui-avatars.com/api/?name=${Uri.encodeComponent(controller.callData["caller_name"])}&background=E5E7EB&color=374151&size=256"
                  : "${Api.publicUrl}storage/${controller.callData["caller_photo"]}";
              return Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                controller.callData["caller_name"] ??
                    controller.nameRechiver.value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Menghubungkan...",
              style: TextStyle(color: Colors.white70),
            ),
            // Tombol untuk receiver
            Obx(() {
              if (!controller.isCaller.value) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tombol reject
                    GestureDetector(
                      onTap: () => controller.rejectCall(
                        controller.callData["call_id"] ??
                            controller.callData["conversation_id"],
                      ),
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.call_end, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 40),
                    // Tombol accept
                    GestureDetector(
                      onTap: () =>
                          controller.acceptCall(controller.callData["call_id"]),
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.call, color: Colors.white),
                      ),
                    ),
                  ],
                );
              }
              // Caller — tombol end saja
              return GestureDetector(
                onTap: () =>
                    controller.endtCall(controller.callData["call_id"]),
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.call_end, color: Colors.white),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildVoiceCall() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 90),
          child: Center(
            child: Obx(
              () => Text(
                controller.callData["caller_name"] ??
                    controller.nameRechiver.value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            "End-to-end encrypted",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Obx(() {
          if (controller.callStatus.value == "accepted") {
            return Text(
              controller.callDuration.value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            );
          }

          String statusText = "Calling...";

          if (!controller.isCaller.value &&
              controller.callStatus.value == "ringing") {
            statusText = "Incoming Call...";
          }

          if (controller.callStatus.value == "rejected") {
            statusText = "Call Rejected";
          }

          if (controller.callStatus.value == "ended") {
            statusText = "Call Ended";
          }

          return Text(
            statusText,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          );
        }),
        const SizedBox(height: 32),
        Obx(() {
          final image = controller.imageRechiver.value.isNotEmpty
              ? controller.imageRechiver.value
              : controller.callData["caller_photo"] == null
              ? "https://ui-avatars.com/api/?name=${Uri.encodeComponent(controller.callData["caller_name"])}&background=E5E7EB&color=374151&size=256"
              : "${Api.publicUrl}storage/${controller.callData["caller_photo"]}";
          return Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        buildCallActions(),
      ],
    );
  }

  Widget buildCallActions() {
    return Obx(() {
      final incomingCall =
          !controller.isCaller.value &&
          controller.callStatus.value == "ringing";

      if (incomingCall) {
        return Container(
          margin: const EdgeInsets.only(left: 32, right: 32, bottom: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // REJECT
              GestureDetector(
                onTap: () {
                  controller.rejectCall(
                    controller.callData["call_id"] ??
                        controller.callData["conversation_id"],
                  );
                },
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

              const SizedBox(width: 48),

              // ACCEPT
              GestureDetector(
                onTap: () {
                  controller.acceptCall(controller.callData["call_id"]);
                },
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call, color: Colors.white, size: 32),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(left: 32, right: 32, bottom: 48),
        decoration: BoxDecoration(
          color: AppColors.borderGreeyColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blueFieldColor,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  "assets/images/slice.png",
                  width: 24,
                  height: 24,
                ),
              ),
            ),

            const SizedBox(width: 16),

            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blueFieldColor,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  "assets/images/mute.png",
                  width: 24,
                  height: 24,
                ),
              ),
            ),

            const SizedBox(width: 16),

            GestureDetector(
              onTap: () {
                controller.endtCall(
                  controller.callData["id"] ?? controller.callData["call_id"],
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  "assets/images/FePhone.png",
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
