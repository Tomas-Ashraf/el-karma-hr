import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/login_view/manager/login_cubit/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.userName, required this.userRole});

  final String userName;
  final String userRole;

  @override
  Widget build(BuildContext context) {
    final entries = <_DrawerEntry>[
      _DrawerEntry(
        icon: Icons.people_alt_outlined,
        label: 'Employees',
        onTap: () {},
      ),
      _DrawerEntry(
        icon: Icons.fingerprint_rounded,
        label: 'Attendance',
        onTap: () {},
      ),
      _DrawerEntry(
        icon: Icons.payments_outlined,
        label: 'Count Salary',
        onTap: () {},
      ),
      _DrawerEntry(
        icon: Icons.edit_calendar_outlined,
        label: 'Record Events',
        onTap: () {},
      ),
      _DrawerEntry(
        icon: Icons.logout_rounded,
        label: 'Logout',
        onTap: () async {
          BlocProvider.of<AuthCubit>(context).logout();
          GoRouter.of(context).pushReplacementNamed(AppRouter.kLoginView);
        },
      ),
    ];

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
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(userRole, style: Styles.textStyle14),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 8),
            for (final entry in entries) _DrawerTile(entry: entry),
          ],
        ),
      ),
    );
  }
}

class _DrawerEntry {
  const _DrawerEntry({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({required this.entry});

  final _DrawerEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(entry.icon, size: 20, color: kPrimaryBlue),
        ),
        title: Text(
          entry.label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
        onTap: () {
          Navigator.of(context).pop(); // يقفل الـ drawer
          entry.onTap();
        },
      ),
    );
  }
}
