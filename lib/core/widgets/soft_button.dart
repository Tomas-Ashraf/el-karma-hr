import 'package:flutter/material.dart';

class SoftButton extends StatelessWidget {
  const SoftButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    // this.background = AppColors.blueSoft,
    // this.foreground = AppColors.blue,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  // final Color background;
  // final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Material(
      // color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: Colors.red),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
