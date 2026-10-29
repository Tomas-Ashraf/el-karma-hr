import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/features/attendance_view.dart/manager/cubit/attendance_report_cubit.dart';
import 'package:el_karma_ph/features/attendance_view.dart/manager/cubit/attendance_report_state.dart';
import 'package:el_karma_ph/features/attendance_view.dart/presentation/view_model/attendance_view_body.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttendanceReportCubit()..loadEmployees(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: BlocBuilder<AttendanceReportCubit, AttendanceReportState>(
            buildWhen: (previous, current) => previous.filter != current.filter,
            builder: (context, state) => Text(
              state.filter?.employee.name ?? context.tr('drawer.attendance'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              final router = GoRouter.of(context);
              router.canPop()
                  ? router.pop()
                  : router.go(AppRouter.kDashboardView);
            },
          ),
        ),
        body: const AttendanceViewBody(),
      ),
    );
  }
}
