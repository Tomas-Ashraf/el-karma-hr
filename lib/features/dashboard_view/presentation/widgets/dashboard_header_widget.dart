import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/circle_icon_button_widget.dart';
import 'package:flutter/material.dart';

class DashboardHeaderWidget extends StatelessWidget {
  const DashboardHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleIconButton(
          icon: Icons.menu_rounded,
          onTap: () => Scaffold.of(context).openDrawer(),
        ),
        const SizedBox(width: 14),
        const Expanded(child: Text('Dashboard', style: Styles.textStyle22B)),
        CircleIconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
      ],
    );
  }
}
