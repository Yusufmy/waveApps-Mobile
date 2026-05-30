import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/utils/api.dart';
import 'package:wive_app/app/utils/colors.dart';

import '../../../../utils/widgets/button_global_widget.dart';
import '../../../../utils/widgets/input_global_widget.dart';
import '../controllers/profile_screen_change_profile_screen_controller.dart';

class ProfileScreenChangeProfileScreenView
    extends GetView<ProfileScreenChangeProfileScreenController> {
  const ProfileScreenChangeProfileScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 12, bottom: 48, left: 16, right: 16),
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
                  const SizedBox(width: 8),
                  Text(
                    "Edit Profile",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Update your personal information and account details.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Stack(
                  children: [
                    Obx(
                      () => Container(
                        width: 100,
                        height: 100,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: Offset(2, 2),
                            ),
                          ],
                          image: controller.userProfile.photo.isEmpty
                              ? null
                              : DecorationImage(
                                  image: NetworkImage(
                                    "${Api.publicUrl}storage/${controller.userProfile.photo.value}",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        child: controller.userProfile.photo.value.isEmpty
                            ? Image.asset("assets/images/profile.png")
                            : const SizedBox(),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          controller.pickImage(context);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Image.asset(
                              "assets/images/edit.png",
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                "Name",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              buildInputGlobalWidget(
                context,
                hintText: "Enter your name",
                textEditingController: controller.changeNameController,
              ),
              const SizedBox(height: 24),
              Text(
                "Email Address",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              buildInputGlobalWidget(
                context,
                hintText: "Enter your email",
                textEditingController: controller.changeEmailController,
              ),

              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: butildButtonGlobalWidget(
                    context,
                    title: "Save",
                    horizontal: 48,
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
