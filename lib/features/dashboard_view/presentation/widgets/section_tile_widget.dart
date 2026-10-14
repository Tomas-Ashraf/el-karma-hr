import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:flutter/widgets.dart';

class SectionTitleWidget extends StatelessWidget {
  const SectionTitleWidget(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Styles.textStyle16.copyWith(
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }
}
