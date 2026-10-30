import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';
import 'package:el_karma_ph/features/records_view/presentation/widgets/record_card.dart';
import 'package:el_karma_ph/features/records_view/presentation/widgets/record_summary_chips.dart';
import 'package:flutter/material.dart';

class HeaderCard extends StatelessWidget {
  const HeaderCard({required this.record});

  final RecordPreview record;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: colors.outlineVariant) : null,
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.employeeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Styles.textStyle20,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.date_range_rounded,
                size: 16,
                color: kPrimaryBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  recordPeriodLabel(context, record),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RecordSummaryChips(record: record),
        ],
      ),
    );
  }
}
