import 'package:el_karma_ph/constants.dart';
import 'package:flutter/material.dart';

class InactiveIllustrationWidget extends StatelessWidget {
  const InactiveIllustrationWidget({super.key, required this.size});

  final double size;

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
            Icons.person_off_outlined,
            size: size * 0.3,
            color: kPrimaryBlue,
          ),
          Positioned(
            right: size * 0.2,
            bottom: size * 0.2,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.block_rounded,
                size: size * 0.16,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
