import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/routes/app_pages.dart';

import '../../../utils/widgets/button_global_widget.dart';
import '../controllers/welcome_screen_controller.dart';

class WelcomeScreenView extends GetView<WelcomeScreenController> {
  const WelcomeScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 60),
          child: Column(
            children: [
              Center(
                child: Image.asset("assets/images/logoWiveApp.png", width: 200),
              ),
              const SizedBox(height: 48),
              Center(
                child: Text(
                  "WiveApp",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 42),
                child: Text(
                  "Connect with friends and teams around the world for free",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black45,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.LOGIN_SCREEN);
                },
                child: butildButtonGlobalWidget(
                  context,
                  title: "Get Started",
                  horizontal: 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
