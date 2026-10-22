import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
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
          children: [
            Text(
              context.tr('login.welcome_back'),
              style: Styles.textStyle26B.copyWith(color: Colors.black),
            ),
            Text('👋', style: TextStyle(fontSize: 24)),
          ],
        ),
        RichText(
          text: TextSpan(
            style: Styles.textStyle26B.copyWith(color: Colors.black),
            children: [
              TextSpan(text: context.tr('login.to')),
              TextSpan(
                text: ' ${context.tr('app.name')}',
                style: TextStyle(color: kPrimaryBlue),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(context.tr('login.subtitle'), style: Styles.textStyle14),
      ],
    );
  }
}
