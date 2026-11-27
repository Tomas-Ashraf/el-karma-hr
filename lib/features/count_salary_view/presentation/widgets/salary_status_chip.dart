import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';
import 'package:flutter/material.dart';

class SalaryStatusChip extends StatelessWidget {
  const SalaryStatusChip({super.key, required this.status});

  final SalaryStatus status;

  @override
  Widget build(BuildContext context) {
    final (String key, Color color, IconData icon) = switch (status) {
      SalaryStatus.notCalculated => (
        'salary.status_pending',
        context.colors.onSurfaceVariant,
        Icons.hourglass_empty_rounded,
      ),
      SalaryStatus.calculated => (
        'salary.status_calculated',
        warning,
        Icons.calculate_outlined,
      ),
      SalaryStatus.paid => (
        'salary.status_paid',
        kBonusColor,
        Icons.check_circle_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            context.tr(key),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
