import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:flutter/material.dart';

/// أيقونة دايرة + نص (+ زرار اختياري) للحالات الفاضية، بنفس شكل شاشة الحضور.
class RecordsMessage extends StatelessWidget {
  const RecordsMessage({
    super.key,
    required this.icon,
    required this.text,
    this.hint,
    this.action,
  });

  final IconData icon;
  final String text;
  final String? hint;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final hintText = hint;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: kPrimaryBlue.withAlpha(31),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: kPrimaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              text,
              style: Styles.textStyle16,
              textAlign: TextAlign.center,
            ),
            if (hintText != null) ...[
              const SizedBox(height: 6),
              Text(
                hintText,
                style: Styles.textStyle14,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
