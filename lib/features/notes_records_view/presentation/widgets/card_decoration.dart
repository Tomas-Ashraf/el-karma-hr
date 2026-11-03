import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

BoxDecoration cardDecoration(BuildContext context) {
  final colors = context.colors;
  final isDark = context.isDark;
  return BoxDecoration(
    color: colors.surface,
    borderRadius: BorderRadius.circular(16),
    border: isDark ? Border.all(color: colors.outlineVariant) : null,
    boxShadow: isDark
        ? null
        : const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
  );
}
