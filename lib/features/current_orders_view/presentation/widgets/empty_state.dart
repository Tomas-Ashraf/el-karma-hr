import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
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
            child: const Icon(
              Icons.motorcycle_rounded,
              size: 34,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(context.tr('orders.empty'), style: Styles.textStyle14),
        ],
      ),
    );
  }
}
