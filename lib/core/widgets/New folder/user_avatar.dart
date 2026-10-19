import 'package:el_karma_ph/core/app_colors.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.size = 46});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.blueSoft,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person_outline, color: AppColors.blue, size: size * .5),
    );
  }
}
