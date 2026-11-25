import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_dummy_data.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustment_card.dart'
    show formatAmount;
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/card_decoration.dart';
import 'package:flutter/material.dart';

class SalaryRecordCard extends StatelessWidget {
  const SalaryRecordCard({super.key, required this.record, this.onTap});

  final SalaryRecord record;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final period =
        '${formatMediumDate(context, record.from)}  -  '
        '${formatMediumDate(context, record.to)}';

    return Container(
      decoration: cardDecoration(context),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: kPrimaryBlue.withAlpha(31),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_note_rounded,
                        size: 22,
                        color: kPrimaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        period,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Chip(
                      text: context.tr(
                        'salary.attended_chip',
                        args: {'n': '${record.attendedDays}'},
                      ),
                      color: kPrimaryBlue,
                    ),
                    if (record.absentDays > 0)
                      _Chip(
                        text: context.tr(
                          'records.absent_count',
                          args: {'n': '${record.absentDays}'},
                        ),
                        color: kDeductionColor,
                      ),
                    if (record.lateMinutes > 0)
                      _Chip(
                        text: context.tr(
                          'records.late_total',
                          args: {
                            'time': formatDuration(context, record.lateMinutes),
                          },
                        ),
                        color: warning,
                      ),
                    if (record.bonus > 0)
                      _Chip(
                        text: context.tr(
                          'salary.bonus_chip',
                          args: {'amount': formatAmount(context, record.bonus)},
                        ),
                        color: kBonusColor,
                      ),
                    if (record.deduction > 0)
                      _Chip(
                        text: context.tr(
                          'salary.deduction_chip',
                          args: {
                            'amount': formatAmount(context, record.deduction),
                          },
                        ),
                        color: kDeductionColor,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: colors.outlineVariant),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('salary.net_salary'),
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      formatAmount(context, record.netSalary),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
