import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/models/dashboard_models.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/stat_card_widget.dart';
import 'package:flutter/material.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    const spacing = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640 ? 4 : 2;
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        final cards = <Widget>[
          StatCardWidget(
            icon: Icons.login_rounded,
            label: context.tr('dashboard.check_in'),
            value: '${stats.checkedIn}',
            subtitle: context.tr('dashboard.employees_unit'),
          ),
          StatCardWidget(
            icon: Icons.logout_rounded,
            label: context.tr('dashboard.check_out'),
            value: '${stats.checkedOut}',
            subtitle: context.tr('dashboard.employees_unit'),
          ),
          StatCardWidget(
            icon: Icons.schedule_rounded,
            label: context.tr('dashboard.late'),
            value: '${stats.late}',
            subtitle: context.tr('dashboard.employees_unit'),
            accentColor: const Color(0xFFEF4444),
          ),
          StatCardWidget(
            icon: Icons.task_alt_rounded,
            label: context.tr('dashboard.on_time'),
            value: '${stats.onTime}',
            subtitle: context.tr('dashboard.employees_unit'),
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
