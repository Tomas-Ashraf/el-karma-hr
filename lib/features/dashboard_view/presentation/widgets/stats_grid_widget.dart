import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/features/dashboard_view/models/dashboard_models.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/attendance_list_sheet.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/stat_card_widget.dart';
import 'package:flutter/material.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;
    final stats = data.stats;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640 ? 4 : 2;
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final unit = context.tr('dashboard.employees_unit');

        void open(
          String titleKey,
          List<EmployeeDayStatus> entries,
          AttendanceListKind kind,
        ) {
          showAttendanceListSheet(
            context,
            title: context.tr(titleKey),
            entries: entries,
            kind: kind,
          );
        }

        final cards = <Widget>[
          StatCardWidget(
            icon: Icons.login_rounded,
            label: context.tr('dashboard.check_in'),
            value: '${stats.checkedIn}',
            subtitle: unit,
            onTap: () => open(
              'dashboard.check_in',
              data.checkedIn,
              AttendanceListKind.checkIn,
            ),
          ),
          StatCardWidget(
            icon: Icons.logout_rounded,
            label: context.tr('dashboard.check_out'),
            value: '${stats.checkedOut}',
            subtitle: unit,
            onTap: () => open(
              'dashboard.check_out',
              data.checkedOut,
              AttendanceListKind.checkOut,
            ),
          ),
          StatCardWidget(
            icon: Icons.schedule_rounded,
            label: context.tr('dashboard.late'),
            value: '${stats.late}',
            subtitle: unit,
            accentColor: const Color(0xFFEF4444),
            onTap: () =>
                open('dashboard.late', data.late, AttendanceListKind.late),
          ),
          StatCardWidget(
            icon: Icons.task_alt_rounded,
            label: context.tr('dashboard.on_time'),
            value: '${stats.onTime}',
            subtitle: unit,
            onTap: () => open(
              'dashboard.on_time',
              data.onTime,
              AttendanceListKind.onTime,
            ),
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}
