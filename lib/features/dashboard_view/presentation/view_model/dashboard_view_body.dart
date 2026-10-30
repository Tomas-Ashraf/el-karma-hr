import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/dashboard_view/manager/cubit/dashboard_attendance_cubit.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/dashboard_header_widget.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/recent_activity_item.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/section_tile_widget.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/stats_grid_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  // static const _recentLimit = 10;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 900.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: RefreshIndicator(
          onRefresh: () =>
              context.read<DashboardAttendanceCubit>().load(silent: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeaderWidget(),
                SizedBox(height: screenSize.height * 0.03),
                BlocBuilder<DashboardAttendanceCubit, DashboardAttendanceState>(
                  builder: (context, state) {
                    if (state is DashboardAttendanceSuccess) {
                      final data = state.data;
                      // final recent = data.recent.take(_recentLimit).toList();
                      final recent = data.recent.toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitleWidget(
                            context.tr('dashboard.today_attendance'),
                          ),
                          const SizedBox(height: 12),
                          StatsGrid(data: data),
                          SizedBox(height: screenSize.height * 0.03),
                          SectionTitleWidget(context.tr('dashboard.recent')),
                          const SizedBox(height: 12),
                          if (recent.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  context.tr('dashboard.empty'),
                                  style: Styles.textStyle14,
                                ),
                              ),
                            )
                          else
                            for (final record in recent)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: RecentActivityItem(record: record),
                              ),
                        ],
                      );
                    }

                    if (state is DashboardAttendanceFailure) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.tr(state.errorMessage),
                                style: Styles.textStyle14,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => context
                                    .read<DashboardAttendanceCubit>()
                                    .load(),
                                child: Text(context.tr('common.retry')),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
