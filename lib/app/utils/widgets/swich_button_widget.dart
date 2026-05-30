import 'package:flutter/material.dart';
import 'package:wive_app/app/utils/colors.dart';

class GlobalSwitchButton extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const GlobalSwitchButton({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<GlobalSwitchButton> createState() => _GlobalSwitchButtonState();
}

class _GlobalSwitchButtonState extends State<GlobalSwitchButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: Container(
        width: 48,
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: widget.value
              ? AppColors.blueColor.withOpacity(0.2)
              : AppColors.borderGreeyColor,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: widget.value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            height: 18,
            width: 18,
            decoration: BoxDecoration(
              color: widget.value ? AppColors.blueColor : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
