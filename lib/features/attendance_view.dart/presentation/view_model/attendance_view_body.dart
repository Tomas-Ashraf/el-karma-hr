import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/attendance_view.dart/manager/cubit/attendance_report_cubit.dart';
import 'package:el_karma_ph/features/attendance_view.dart/manager/cubit/attendance_report_state.dart';
import 'package:el_karma_ph/features/attendance_view.dart/presentation/widgets/attendance_entry_card.dart';
import 'package:el_karma_ph/features/attendance_view.dart/presentation/widgets/attendance_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceViewBody extends StatelessWidget {
  const AttendanceViewBody({super.key});

  Future<void> _openFilter(BuildContext context) async {
    final cubit = context.read<AttendanceReportCubit>();
    final state = cubit.state;
    if (state.employees.isEmpty) return;

    final result = await showAttendanceFilterDialog(
      context,
      employees: state.employees,
      initial: state.filter,
    );
    if (result != null) cubit.calculate(result);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 600.0;

    return BlocConsumer<AttendanceReportCubit, AttendanceReportState>(
      listenWhen: (previous, current) =>
          previous.status == AttendanceReportStatus.loadingEmployees &&
          current.status == AttendanceReportStatus.ready,
      listener: (context, state) => _openFilter(context),
      builder: (context, state) {
        final filter = state.filter;
        final label = filter == null
            ? context.tr('attendance.select_period')
            : '${formatMediumDate(context, filter.from)}  -  '
                  '${formatMediumDate(context, filter.to)}';

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05,
                  vertical: screenSize.height * 0.015,
                ),
                child: Column(
                  children: [
                    _PeriodButton(
                      label: label,
                      onTap: state.employees.isEmpty
                          ? null
                          : () => _openFilter(context),
                    ),
                    const SizedBox(height: 12),
                    Expanded(child: _Content(state: state)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.date_range_rounded, color: kPrimaryBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.tune_rounded, size: 20, color: kPrimaryBlue),
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final AttendanceReportState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case AttendanceReportStatus.loadingEmployees:
      case AttendanceReportStatus.calculating:
        return const Center(child: CircularProgressIndicator());

      case AttendanceReportStatus.failure:
        final cubit = context.read<AttendanceReportCubit>();
        final filter = state.filter;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr(state.message ?? 'attendance.load_failed'),
                style: Styles.textStyle14,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => filter == null
                    ? cubit.loadEmployees()
                    : cubit.calculate(filter),
                child: Text(context.tr('common.retry')),
              ),
            ],
          ),
        );

      case AttendanceReportStatus.ready:
        return state.employees.isEmpty
            ? _Message(
                icon: Icons.people_outline_rounded,
                text: context.tr('employees.empty'),
              )
            : _Message(
                icon: Icons.event_note_outlined,
                text: context.tr('attendance.prompt'),
              );

      case AttendanceReportStatus.success:
        if (state.entries.isEmpty) {
          return _Message(
            icon: Icons.event_busy_outlined,
            text: context.tr('attendance.empty'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: state.entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              AttendanceEntryCard(entry: state.entries[index]),
        );
    }
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: kPrimaryBlue.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: kPrimaryBlue),
          ),
          const SizedBox(height: 16),
          Text(text, style: Styles.textStyle14, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
