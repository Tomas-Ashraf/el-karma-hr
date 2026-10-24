import 'package:el_karma_ph/core/app_colors.dart';
import 'package:flutter/material.dart';

class AddShiftButton extends StatelessWidget {
  const AddShiftButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.blueSoft,
          foregroundColor: AppColors.blue,
          side: const BorderSide(color: AppColors.blue, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          '+ Add shift',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
