import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../routes/app_pages.dart';
import '../../../../utils/widgets/button_global_widget.dart';
import '../../../../utils/widgets/input_global_widget.dart';
import '../controllers/register_screen_controller.dart';

class RegisterScreenView extends GetView<RegisterScreenController> {
  const RegisterScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    RegisterScreenController controller = Get.put(RegisterScreenController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 60, bottom: 48),
        child: Column(
          children: [
            Center(
              child: Image.asset("assets/images/logoWiveApp.png", width: 180),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: buildInputGlobalWidget(
                context,
                hintText: "Name",
                textEditingController: controller.nameController,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: buildInputGlobalWidget(
                context,
                hintText: "Email",
                textEditingController: controller.emailController,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: buildInputGlobalWidget(
                context,
                hintText: "Password",
                textEditingController: controller.passwordController,
                isPassword: true,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: buildInputGlobalWidget(
                context,
                hintText: "Confrim Password",
                textEditingController: controller.confrimPasswordController,
                isPassword: true,
              ),
            ),
            const SizedBox(height: 48),
            Obx(
              () => GestureDetector(
                onTap: controller.isRegister.value
                    ? null
                    : () {
                        controller.register(context);
                      },
                child: butildButtonGlobalWidget(
                  context,
                  title: "Register",
                  horizontal: 48,
                ),
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                "Already have an account?",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.LOGIN_SCREEN);
                },
                child: Text(
                  "Login",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
