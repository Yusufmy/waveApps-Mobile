import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wive_app/app/utils/colors.dart';

Widget butildButtonGlobalWidget(
  BuildContext context, {
  String? title,
  double? horizontal,
}) {
  return Container(
    height: 48,
    padding: EdgeInsets.symmetric(horizontal: horizontal ?? 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.blueColor,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Text(
      "$title",
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );
}

