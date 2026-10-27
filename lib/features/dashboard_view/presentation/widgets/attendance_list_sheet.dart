import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/dashboard_view/models/dashboard_models.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/initials_avatar.dart';
import 'package:flutter/material.dart';

enum AttendanceListKind { checkIn, checkOut, late, onTime }

const _lateColor = Color(0xFFEF4444);
const _onTimeColor = Color(0xFF22C55E);

Future<void> showAttendanceListSheet(
  BuildContext context, {
  required String title,
  required List<EmployeeDayStatus> entries,
  required AttendanceListKind kind,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        _AttendanceListSheet(title: title, entries: entries, kind: kind),
  );
}

class _AttendanceListSheet extends StatelessWidget {
  const _AttendanceListSheet({
    required this.title,
    required this.entries,
    required this.kind,
  });

  final String title;
  final List<EmployeeDayStatus> entries;
  final AttendanceListKind kind;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                '$title (${entries.length})',
                style: Styles.textStyle20,
              ),
            ),
            Divider(height: 1, color: context.colors.outlineVariant),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    context.tr('dashboard.empty'),
                    style: Styles.textStyle14,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) =>
                      _EntryRow(entry: entries[index], kind: kind),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.kind});

  final EmployeeDayStatus entry;
  final AttendanceListKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final time = kind == AttendanceListKind.checkOut
        ? entry.lastCheckOut
        : entry.firstCheckIn;

    Widget? extra;
    if (kind == AttendanceListKind.late) {
      extra = Text(
        context.tr('dashboard.late_by', args: {'min': '${entry.minutesLate}'}),
        style: const TextStyle(fontSize: 12, color: _lateColor),
      );
    } else if (kind == AttendanceListKind.checkIn) {
      extra = Text(
        entry.isLate
            ? context.tr('dashboard.late')
            : context.tr('dashboard.on_time'),
        style: TextStyle(
          fontSize: 12,
          color: entry.isLate ? _lateColor : _onTimeColor,
        ),
      );
    }

    return Row(
      children: [
        InitialsAvatar(initials: entry.employee.initials),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.employee.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                entry.employee.job,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (time != null)
              Text(
                formatTime(context, time),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (extra != null) ...[const SizedBox(height: 2), extra],
          ],
        ),
      ],
    );
  }
}
