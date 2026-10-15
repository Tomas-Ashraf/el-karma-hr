// ignore_for_file: unused_element

import 'package:el_karma_ph/core/utils/app_router.dart';
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
  @override
  Widget build(BuildContext context) {
    late final Future<UserModel> userFuture = context
        .read<DashboardCubit>()
        .getUserData();

    final entries = <DrawerEntry>[
      DrawerEntry(
        icon: Icons.people_alt_outlined,
        label: 'Employees',
        onTap: () {},
      ),
      DrawerEntry(
        icon: Icons.fingerprint_rounded,
        label: 'Attendance',
        onTap: () {},
      ),
      DrawerEntry(
        icon: Icons.edit_calendar_outlined,
        label: 'Attendance Records',
        onTap: () {},
      ),
      DrawerEntry(
        icon: Icons.edit_calendar_outlined,
        label: 'Notes Records',
        onTap: () {},
      ),
      DrawerEntry(
        icon: Icons.payments_outlined,
        label: 'Count Salary',
        onTap: () {},
      ),

      DrawerEntry(
        icon: Icons.settings_outlined,
        label: 'Settings',
        onTap: () => GoRouter.of(context).pushNamed(AppRouter.kSettingsView),
      ),
      DrawerEntry(
        icon: Icons.logout_rounded,
        label: 'Logout',
        onTap: () async {
          final router = GoRouter.of(context);
          final authCubit = context.read<AuthCubit>();

          await authCubit.logout();
          router.goNamed(AppRouter.kLoginView); // بيمسح الـ stack كله
        },
      ),
    ];

    return FutureBuilder(
      future: userFuture,
      builder: (context, asyncSnapshot) {
        UserModel? userModel = asyncSnapshot.data;
        return Drawer(
          backgroundColor: Colors.white,
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
                        userModel!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(userModel.job, style: Styles.textStyle14),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
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
