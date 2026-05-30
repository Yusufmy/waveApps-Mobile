import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/utils/colors.dart';

Widget buildInputGlobalWidget(
  BuildContext context, {
  String? hintText,
  TextEditingController? textEditingController,
  bool isPassword = false,
}) {
  final obscureNotifier = ValueNotifier(true);
  return Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black38),
    ),
    child: ValueListenableBuilder(
      valueListenable: obscureNotifier,
      builder: (context, obscureText, child) {
        return TextFormField(
          controller: textEditingController,
          obscureText: isPassword ? obscureText : false,
          cursorColor: AppColors.blueColor,
          cursorHeight: 20,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              fontSize: 16,
            ),
            border: InputBorder.none,
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: () {
                      obscureNotifier.value = !obscureNotifier.value;
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Image.asset(
                        obscureText
                            ? "assets/images/endShow.png"
                            : "assets/images/show.png",
                        width: 24,
                        height: 24,
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    ),
  );
}
