import 'package:el_karma_ph/core/app_colors.dart';
import 'package:el_karma_ph/core/widgets/New%20folder/app_decorations.dart';
import 'package:el_karma_ph/core/widgets/New%20folder/soft_button.dart';
import 'package:flutter/material.dart';

/// A single value in its own card with an action button on the side.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.label,
    required this.child,
    required this.actionLabel,
    required this.onAction,
  });

  final String label;
  final Widget child;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppDecorations.softCard(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
          const SizedBox(width: 12),
          SoftButton(label: actionLabel, onTap: onAction),
        ],
      ),
    );
  }
}
