import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/utils/colors.dart';

import '../controllers/call_detail_screen_controller.dart';

class CallDetailScreenView extends GetView<CallDetailScreenController> {
  const CallDetailScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 90),
            child: Center(
              child: Obx(
                () => Text(
                  controller.callData["caller_name"] ?? "",
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
          Text(
            "23:00",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage("assets/images/profile.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const Spacer(),
          Obx(() {
            final incomingCall =
                !controller.isCaller.value &&
                controller.callStatus.value == "ringing";

            if (incomingCall) {
              return Container(
                margin: const EdgeInsets.only(left: 32, right: 32, bottom: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // REJECT
                    GestureDetector(
                      onTap: () {
                        controller.rejectCall(controller.callData["call_id"]);
                      },
                      child: Container(
                        width: 72,
                        height: 72,
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
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call,
                          color: Colors.white,
                          size: 32,
                        ),
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
                      print(controller.callData);
                      print(controller.callData["id"]);

                      controller.endtCall(controller.callData["id"]);
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
          }),
          // Container(
          //   padding: EdgeInsets.all(16),
          //   margin: const EdgeInsets.only(left: 32, right: 32, bottom: 48),
          //   decoration: BoxDecoration(
          //     color: AppColors.borderGreeyColor,
          //     borderRadius: BorderRadius.circular(100),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Container(
          //         padding: const EdgeInsets.all(12),
          //         decoration: BoxDecoration(
          //           color: AppColors.blueFieldColor,
          //           shape: BoxShape.circle,
          //         ),
          //         child: Center(
          //           child: Image.asset(
          //             "assets/images/slice.png",
          //             width: 24,
          //             height: 24,
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 16),
          //       Container(
          //         padding: const EdgeInsets.all(12),
          //         decoration: BoxDecoration(
          //           color: AppColors.blueFieldColor,
          //           shape: BoxShape.circle,
          //         ),
          //         child: Center(
          //           child: Image.asset(
          //             "assets/images/mute.png",
          //             width: 24,
          //             height: 24,
          //           ),
          //         ),
          //       ),
          //       const SizedBox(width: 16),
          //       Container(
          //         padding: const EdgeInsets.all(12),
          //         decoration: BoxDecoration(
          //           color: AppColors.redColor,
          //           shape: BoxShape.circle,
          //         ),
          //         child: Center(
          //           child: Image.asset(
          //             "assets/images/FePhone.png",
          //             width: 24,
          //             height: 24,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
