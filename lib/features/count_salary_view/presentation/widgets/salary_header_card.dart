import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/employee_jobs.dart';
import 'package:el_karma_ph/core/utils/money_format.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/initials_avatar.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/card_decoration.dart';
import 'package:flutter/material.dart';

class SalaryHeaderCard extends StatelessWidget {
  const SalaryHeaderCard({super.key, required this.employee});

  final EmployeeModel employee;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(context),
      child: Row(
        children: [
          InitialsAvatar(initials: employee.initials, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textStyle20,
                ),
                const SizedBox(height: 2),
                Text(
                  jobLabel(context, employee.job),
                  style: Styles.textStyle14,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                context.tr('salary.base_salary'),
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                formatAmount(context, employee.salary),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
