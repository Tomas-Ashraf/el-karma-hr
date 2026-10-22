import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/models/dashboard_models.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/dashboard_header_widget.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/recent_activity_item.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/section_tile_widget.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/stats_grid_widget.dart';
import 'package:flutter/material.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 900.0;

    const stats = sampleStats;
    final recent = sampleRecentActivities();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.05,
            vertical: screenSize.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardHeaderWidget(),
              SizedBox(height: screenSize.height * 0.03),
              SectionTitleWidget(context.tr('dashboard.today_attendance')),
              const SizedBox(height: 12),
              const StatsGrid(stats: stats),
              SizedBox(height: screenSize.height * 0.03),
              SectionTitleWidget(context.tr('dashboard.recent')),
              const SizedBox(height: 12),
              for (final activity in recent)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RecentActivityItem(activity: activity),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
