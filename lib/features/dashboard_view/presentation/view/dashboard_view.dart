import 'package:el_karma_ph/features/dashboard_view/manager/cubit/dashboard_attendance_cubit.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/app_drawer/view/app_drawer.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/view_model/dashboard_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (_) => DashboardAttendanceCubit()..load(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        drawer: const AppDrawer(),
        body: SafeArea(top: true, child: const HomeViewBody()),
      ),
    );
  }
}
