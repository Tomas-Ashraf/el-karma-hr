import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/core/utils/weekdays.dart';
import 'package:el_karma_ph/features/attendance_exception_view/models/attendance_exception_models.dart';
import 'package:flutter/material.dart';

extension ExceptionTypeUi on ExceptionType {
  String get labelKey => switch (this) {
    ExceptionType.lateArrival => 'exceptions.late_arrival',
    ExceptionType.earlyLeave => 'exceptions.early_leave',
    ExceptionType.dayOff => 'exceptions.day_off',
  };

  IconData get icon => switch (this) {
    ExceptionType.lateArrival => Icons.login_rounded,
    ExceptionType.earlyLeave => Icons.logout_rounded,
    ExceptionType.dayOff => Icons.beach_access_outlined,
  };

  Color get color => switch (this) {
    ExceptionType.lateArrival => warning,
    ExceptionType.earlyLeave => kDeductionColor,
    ExceptionType.dayOff => kPrimaryBlue,
  };
}

class ExceptionCard extends StatelessWidget {
  const ExceptionCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final AttendanceException item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final color = item.type.color;
    final time = item.time;
    final reason = item.reason.trim();

    String? timeText;
    if (time != null) {
      final key = item.type == ExceptionType.lateArrival
          ? 'exceptions.arrive_at'
          : 'exceptions.leave_at';
      timeText = context.tr(key, args: {'time': time.format(context)});
    }

    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 6, 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(31),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.type.icon, size: 22, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(item.type.labelKey),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      if (timeText != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          timeText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (reason.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          reason,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${context.tr('day.${weekdayKey(item.date)}')} · '
                        '${formatMediumDate(context, item.date)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: context.tr('common.delete'),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 22,
                    color: kDeductionColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
