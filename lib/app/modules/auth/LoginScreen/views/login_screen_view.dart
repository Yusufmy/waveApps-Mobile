import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../routes/app_pages.dart';
import '../../../../utils/widgets/button_global_widget.dart';
import '../../../../utils/widgets/input_global_widget.dart';
import '../controllers/login_screen_controller.dart';

class LoginScreenView extends GetView<LoginScreenController> {
  const LoginScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    LoginScreenController controller = Get.put(LoginScreenController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 60),
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
              const SizedBox(height: 48),
              Obx(
                () => GestureDetector(
                  onTap: controller.isLogin.value
                      ? null
                      : () {
                          controller.login(context);
                        },
                  child: butildButtonGlobalWidget(
                    context,
                    title: "Login",
                    horizontal: 48,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: Text(
                  "Don't have an account yet?",
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
                    Get.toNamed(Routes.REGISTER_SCREEN);
                  },
                  child: Text(
                    "Register",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 32),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       height: 48,
              //       width: 48,
              //       decoration: BoxDecoration(
              //         color: Colors.grey[100],
              //         shape: BoxShape.circle,
              //       ),
              //       child: Center(
              //         child: Image.asset("assets/images/logoGoogle.png"),
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Container(
              //       height: 48,
              //       width: 48,
              //       decoration: BoxDecoration(
              //         color: Colors.grey[100],
              //         shape: BoxShape.circle,
              //       ),
              //       child: Center(
              //         child: Image.asset("assets/images/logoApple.png"),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
