import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/routes/app_pages.dart';
import 'package:wive_app/app/utils/api.dart';
import 'package:wive_app/app/utils/colors.dart';

import '../../../common/delete.dart';
import '../../../utils/widgets/button_global_widget.dart';
import '../../../utils/widgets/swich_button_widget.dart';
import '../controllers/profile_screen_controller.dart';

class ProfileScreenView extends GetView<ProfileScreenController> {
  const ProfileScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    ProfileScreenController controller = Get.put(ProfileScreenController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 12, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                child: buildAppBar(),
              ),
              const SizedBox(height: 32),
              Obx(() {
                return Padding(
                  padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
                  child: Center(
                    child: buildImageProfile(
                      images: controller.userProfile.photo.value,
                      name: controller.userProfile.name.value,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
                child: buildContainer(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppBar() {
    return Text(
      "Profile",
      style: GoogleFonts.poppins(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget buildImageProfile({String? images, String? name}) {
    return Column(
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 0),
              ),
            ],
            image: images == null || images.isEmpty
                ? null
                : DecorationImage(
                    image: NetworkImage("${Api.publicUrl}storage/$images"),
                    fit: BoxFit.cover,
                  ),
          ),
          child: images == null || images.isEmpty
              ? Image.asset("assets/images/profile.png")
              : const SizedBox(),
        ),
        const SizedBox(height: 32),
        Text(
          "$name",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget buildContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.borderGreeyColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.CHANGE_PROFILE_SCREEN);
            },
            child: Container(
              height: 72,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/profile.png",
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Setting Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Change your profile",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textGreeyColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Image.asset(
                    "assets/images/arrow_right.png",
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 72,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/iconDarkMode.png",
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  "Dark Mode",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => GlobalSwitchButton(
                    value: controller.isNotification.value,
                    onChanged: (value) {
                      controller.isNotification.value = value;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 72,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Image.asset("assets/images/info.png", width: 24, height: 24),
                const SizedBox(width: 16),
                Text(
                  "Terms & Conditions",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              await logout(context, controller.isLogout.value);
            },
            child: Container(
              height: 72,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/logout.png",
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //   Widget buildColContainer({
  //     String? title,
  //     String? subTitle,
  //     String? icon,
  // }){
  //     return Container(
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(16),
  //         color: Colors.white,
  //       ),
  //       child: Row(
  //         children: [
  //           Image.asset("assets/images/profile.png", width: 24, height: 24,),
  //           const SizedBox(width: 16,),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text("Setting Profile", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),),
  //               Text("Change your profile", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textGreeyColor),),
  //             ],
  //           ),
  //           const Spacer(),
  //           Image.asset("assets/images/arrow_right.png", width: 24,height: 24,)
  //         ],
  //       ),
  //     )
  //   }
}
