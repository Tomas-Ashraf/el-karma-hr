import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({super.key, required this.width, required this.height, this.onPressed, required this.backgroundColor, required this.foregroundColor, required this.text});
  final double width;
  final double height;
  final void Function()? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: text,
      ),
    );
  }
}