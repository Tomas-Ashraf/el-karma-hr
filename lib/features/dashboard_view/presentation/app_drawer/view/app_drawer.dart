import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/dashboard_view/manager/cubit/dashboard_cubit.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/app_drawer/models/drawer_entry_model.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/app_drawer/widgets/drawer_tile_widget.dart';
import 'package:el_karma_ph/features/login_view/manager/login_cubit/cubit/auth_cubit.dart';
import 'package:el_karma_ph/features/login_view/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late final Future<UserModel> _userFuture = context
      .read<DashboardCubit>()
      .getUserData();

  @override
  Widget build(BuildContext context) {
    final entries = <DrawerEntry>[
      DrawerEntry(
        icon: Icons.people_alt_outlined,
        label: context.tr('drawer.employees'),
        onTap: () =>
            GoRouter.of(context).pushNamed(AppRouter.kEmployeeListView),
      ),
      DrawerEntry(
        icon: Icons.fingerprint_rounded,
        label: context.tr('drawer.attendance'),
        onTap: () => GoRouter.of(context).pushNamed(AppRouter.kAttendanceView),
      ),
      DrawerEntry(
        icon: Icons.edit_calendar_outlined,
        label: context.tr('drawer.attendance_records'),
        onTap: () {},
      ),
      DrawerEntry(
        icon: Icons.edit_calendar_outlined,
        label: context.tr('drawer.notes_records'),
        onTap: () {},
      ),
      DrawerEntry(
        icon: Icons.payments_outlined,
        label: context.tr('drawer.count_salary'),
        onTap: () {},
      ),
      DrawerEntry(
        icon: Icons.settings_outlined,
        label: context.tr('drawer.settings'),
        onTap: () => GoRouter.of(context).pushNamed(AppRouter.kSettingsView),
      ),
      DrawerEntry(
        icon: Icons.logout_rounded,
        label: context.tr('drawer.logout'),
        onTap: () async {
          final router = GoRouter.of(context);
          final authCubit = context.read<AuthCubit>();

          await authCubit.logout();
          router.goNamed(AppRouter.kLoginView);
        },
      ),
    ];

    return FutureBuilder<UserModel>(
      future: _userFuture,
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Drawer(
          backgroundColor: context.colors.surface,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(user?.job ?? '', style: Styles.textStyle14),
                    ],
                  ),
                ),
                Divider(height: 1, color: context.colors.outlineVariant),
                const SizedBox(height: 8),
                for (final entry in entries) DrawerTile(entry: entry),
              ],
            ),
          ),
        );
      },
    );
  }
}
