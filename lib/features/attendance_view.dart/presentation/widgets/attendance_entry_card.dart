import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/core/utils/weekdays.dart';
import 'package:el_karma_ph/features/attendance_view.dart/models/attendance_entry.dart';
import 'package:el_karma_ph/features/dashboard_view/models/dashboard_models.dart';
import 'package:flutter/material.dart';

const _lateColor = Color(0xFFEF4444);
const _onTimeColor = Color(0xFF22C55E);
const _warnColor = Color(0xFFF59E0B);

class AttendanceEntryCard extends StatelessWidget {
  const AttendanceEntryCard({super.key, required this.entry});

  final AttendanceEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final record = entry.record;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      child: record == null
          ? _StatusRow(entry: entry)
          : _AttendedRow(entry: entry, record: record),
    );
  }
}

class _AttendedRow extends StatelessWidget {
  const _AttendedRow({required this.entry, required this.record});

  final AttendanceEntry entry;
  final ShiftAttendance record;

  @override
  Widget build(BuildContext context) {
    final checkIn = record.checkIn;

    final (String inNote, Color inColor) = checkIn == null
        ? (context.tr('dashboard.no_check_in'), _warnColor)
        : record.isLate
        ? (
            context.tr(
              'dashboard.late_by',
              args: {'min': '${record.minutesLate}'},
            ),
            _lateColor,
          )
        : (context.tr('dashboard.on_time'), _onTimeColor);

    final outNote = record.leftEarly
        ? context.tr(
            'dashboard.left_early_by',
            args: {'min': '${record.minutesEarly}'},
          )
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _TimeColumn(
            icon: Icons.login_rounded,
            label: context.tr('dashboard.check_in'),
            time: checkIn,
            day: entry.day,
            note: inNote,
            noteColor: inColor,
          ),
        ),
        Expanded(
          flex: 3,
          child: _DayColumn(day: entry.day, shiftNumber: entry.shiftNumber),
        ),
        Expanded(
          flex: 3,
          child: _TimeColumn(
            icon: Icons.logout_rounded,
            label: context.tr('dashboard.check_out'),
            time: record.checkOut,
            day: entry.day,
            note: outNote,
            noteColor: _lateColor,
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.icon,
    required this.label,
    required this.time,
    required this.day,
    this.note,
    this.noteColor,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final DateTime? time;
  final DateTime day;
  final String? note;
  final Color? noteColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;
    final t = time;
    final n = note;

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: kPrimaryBlue),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          t == null ? '—' : formatTime(context, t),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        if (t != null && !_sameDay(t, day))
          Text(
            formatShortDate(context, t),
            style: TextStyle(fontSize: 11, color: muted),
          ),
        if (n != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              n,
              textAlign: alignEnd ? TextAlign.end : TextAlign.start,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: noteColor,
              ),
            ),
          ),
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({required this.day, this.shiftNumber});

  final DateTime day;
  final int? shiftNumber;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.tr('day.${weekdayKey(day)}'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          formatShortDate(context, day),
          style: TextStyle(fontSize: 12, color: muted),
        ),
        if (shiftNumber != null) ...[
          const SizedBox(height: 2),
          Text(
            context.tr('add_employee.shift_title', args: {'n': '$shiftNumber'}),
            style: const TextStyle(fontSize: 11, color: kPrimaryBlue),
          ),
        ],
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.entry});

  final AttendanceEntry entry;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;
    final isAbsent = entry.kind == AttendanceEntryKind.absent;
    final color = isAbsent ? _lateColor : kPrimaryBlue;
    final text = isAbsent
        ? context.tr('attendance.absent')
        : context.tr('add_employee.day_off');
    final shift = entry.shiftNumber;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('day.${weekdayKey(entry.day)}'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatShortDate(context, entry.day),
                style: TextStyle(fontSize: 12, color: muted),
              ),
              if (shift != null) ...[
                const SizedBox(height: 2),
                Text(
                  context.tr('add_employee.shift_title', args: {'n': '$shift'}),
                  style: const TextStyle(fontSize: 11, color: kPrimaryBlue),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        ),
      ],
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
