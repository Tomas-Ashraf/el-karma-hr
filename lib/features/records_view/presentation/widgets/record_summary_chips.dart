import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';
import 'package:flutter/material.dart';

const _absentColor = Color(0xFFEF4444);
const _lateColor = Color(0xFFF59E0B);

/// شارات صغيرة بتلخّص السجل: عدد الأيام والغياب والتأخير.
class RecordSummaryChips extends StatelessWidget {
  const RecordSummaryChips({super.key, required this.record});

  final RecordPreview record;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _Chip(
          text: context.tr(
            'records.days_count',
            args: {'n': '${record.daysCount}'},
          ),
          color: kPrimaryBlue,
        ),
        if (record.absentCount > 0)
          _Chip(
            text: context.tr(
              'records.absent_count',
              args: {'n': '${record.absentCount}'},
            ),
            color: _absentColor,
          ),
        if (record.lateMinutesTotal > 0)
          _Chip(
            text: context.tr(
              'records.late_total',
              args: {'min': '${record.lateMinutesTotal}'},
            ),
            color: _lateColor,
          ),
      ],
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
