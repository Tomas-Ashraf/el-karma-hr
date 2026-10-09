import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:flutter/material.dart';

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text('Welcome Back ', style: Styles.textStyle26B),
            Text('👋', style: TextStyle(fontSize: 24)),
          ],
        ),
        RichText(
          text: const TextSpan(
            style: Styles.textStyle26B,
            children: [
              TextSpan(text: 'to '),
              TextSpan(
                text: 'El-Karma HR',
                style: TextStyle(color: kPrimaryBlue),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('Hello there, login to continue', style: Styles.textStyle14),
      ],
    );
  }
}
