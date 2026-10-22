import 'package:el_karma_ph/constants.dart';
import 'package:flutter/material.dart';

/// الثيم الفاتح والداكن للتطبيق كله.
///
/// الألوان معرّفة هنا مرة واحدة، والشاشات بتاخدها من الثيم:
///   context.colors.surface           → لون الكروت والـ drawer
///   context.colors.onSurface         → لون النص الأساسي
///   context.colors.onSurfaceVariant  → لون النص الثانوي
///   context.colors.outlineVariant    → لون الحدود والفواصل
/// ولون خلفية الصفحة بيتحط تلقائي على الـ Scaffold.
class AppTheme {
  AppTheme._();

  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final pageBackground = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark
        ? const Color(0xFFF1F5F9)
        : const Color(0xFF1A1A1A);
    final textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF6B7280);
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    final scheme =
        ColorScheme.fromSeed(
          seedColor: kPrimaryBlue,
          brightness: brightness,
        ).copyWith(
          primary: kPrimaryBlue,
          surface: card,
          onSurface: textPrimary,
          onSurfaceVariant: textSecondary,
          outlineVariant: border,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: pageBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: border),
    );
  }
}

extension AppThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
