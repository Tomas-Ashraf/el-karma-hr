import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/models/dashboard_models.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/recent_activity_item.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/stat_card_widget.dart';
import 'package:flutter/material.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 900.0;

    const stats = sampleStats;
    final recent = sampleRecentActivities();

    return SafeArea(
      child: Center(
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
                const _DashboardHeader(),
                SizedBox(height: screenSize.height * 0.03),
                const _SectionTitle('Today Attendance'),
                const SizedBox(height: 12),
                const _StatsGrid(stats: stats),
                SizedBox(height: screenSize.height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionTitle('Recent'),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: kPrimaryBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
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
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.menu_rounded,
          onTap: () => Scaffold.of(context).openDrawer(),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        _CircleIconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: Color(0xFFE5E7EB))),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: const Color(0xFF1A1A1A)),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }
}

/// 2x2 على الموبايل، وصف واحد من 4 كروت على الشاشات العريضة.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

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
            label: 'Check In',
            value: '${stats.checkedIn}',
            subtitle: 'Employees',
          ),
          StatCardWidget(
            icon: Icons.logout_rounded,
            label: 'Check Out',
            value: '${stats.checkedOut}',
            subtitle: 'Employees',
          ),
          StatCardWidget(
            icon: Icons.schedule_rounded,
            label: 'Late',
            value: '${stats.late}',
            subtitle: 'Employees',
            accentColor: const Color(0xFFEF4444),
          ),
          StatCardWidget(
            icon: Icons.task_alt_rounded,
            label: 'On Time',
            value: '${stats.onTime}',
            subtitle: 'Employees',
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
