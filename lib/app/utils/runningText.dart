import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RunningText extends StatefulWidget {
  final String text;

  const RunningText({super.key, required this.text});

  @override
  State<RunningText> createState() => _RunningTextState();
}

class _RunningTextState extends State<RunningText>
    with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();

  double opacity = 1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startAnimation();
    });
  }

  Future<void> startAnimation() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 1));

      if (!scrollController.hasClients) continue;

      final maxScroll = scrollController.position.maxScrollExtent;

      if (maxScroll <= 0) continue;

      // jalan ke kiri
      await scrollController.animateTo(
        maxScroll,
        duration: const Duration(seconds: 4),
        curve: Curves.linear,
      );

      // fade out
      if (!mounted) return;
      setState(() => opacity = 0);

      await Future.delayed(const Duration(milliseconds: 600));

      // balik ke awal
      scrollController.jumpTo(0);

      // fade in
      if (!mounted) return;
      setState(() => opacity = 1);

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 600),
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Text(
            widget.text,
            maxLines: 1,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
