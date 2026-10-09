import 'package:el_karma_ph/core/utils/assets.dart' show AssetsData;
import 'package:flutter/material.dart';

class ElKarmaLogoWidget extends StatelessWidget {
  const ElKarmaLogoWidget({
    super.key,
    required this.width,
    required this.height,
  });
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(AssetsData.logo),
    );
  }
}
