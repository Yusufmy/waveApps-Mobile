import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/api.dart';
import '../../../utils/colors.dart';
import '../controllers/call_screen_controller.dart';

class CallScreenView extends GetView<CallScreenController> {
  const CallScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    CallScreenController controller = Get.put(CallScreenController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 12, bottom: 48),

          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
                child: buildAppBar(controller),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                child: buildSearch(),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
                child: buildCall(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppBar(CallScreenController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Calls",
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
              color: Colors.grey,
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
    );
  }

  Widget buildSearch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "23",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 40,
              ),
            ),
            Text(
              "audio, video calls",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textGreeyColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.borderGreeyColor),
          ),
          child: Row(
            children: [
              Image.asset(
                "assets/images/search.png",
                width: 24,
                height: 24,
                color: Colors.black26,
              ),
              const SizedBox(width: 16),
              Text(
                "Search friends",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black26,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCall() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Chats",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          ...controller.historyCallList.map((call) {
            final opponent = controller.getOpponent(call);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  margin: const EdgeInsets.only(bottom: 24),
                  // padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black26, width: 1),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        "${Api.publicUrl}storage/${opponent['photo']}",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opponent['name'] ?? '-',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      call['type'] == 'video' ? 'Video Call' : 'Voice Call',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textGreeyColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.borderGreeyColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.getCallIcon(call),
                    size: 14,
                    color: controller.getCallIconColor(call),
                  ),
                  // child: Center(
                  //   child: Image.asset(
                  //     "assets/images/phoneCall.png",
                  //     width: 18,
                  //     height: 18,
                  //   ),
                  // ),
                ),
              ],
            );
          }),
        ],
      );
    });
  }
}
