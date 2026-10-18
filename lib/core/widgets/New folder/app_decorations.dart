import 'package:flutter/material.dart';

import '../../app_colors.dart';

abstract final class AppDecorations {
  static const _softShadow = BoxShadow(
    color: Color(0x141E283C),
    blurRadius: 18,
    offset: Offset(0, 4),
  );

  static BoxDecoration softCard({double radius = 16}) => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [_softShadow],
  );

  static const List<BoxShadow> primaryShadow = [
    BoxShadow(color: Color(0x592F8CF5), blurRadius: 20, offset: Offset(0, 8)),
  ];
}
