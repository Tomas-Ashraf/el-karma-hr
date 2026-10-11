import 'package:el_karma_ph/constants.dart';
import 'package:flutter/material.dart';

class ForgotPasswordIllustration extends StatelessWidget {
  final double size;

  const ForgotPasswordIllustration({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: size * 0.55,
            height: size * 0.55,
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
          ),
          Icon(
            Icons.lock_reset_rounded,
            size: size * 0.35,
            color: kPrimaryBlue,
          ),
          Positioned(
            top: size * 0.12,
            right: size * 0.12,
            child: Icon(Icons.key_rounded, size: size * 0.16, color: kDarkBlue),
          ),
          Positioned(
            bottom: size * 0.14,
            left: size * 0.12,
            child: Icon(
              Icons.mail_outline_rounded,
              size: size * 0.14,
              color: const Color(0xFF93C5FD),
            ),
          ),
        ],
      ),
    );
  }
}
