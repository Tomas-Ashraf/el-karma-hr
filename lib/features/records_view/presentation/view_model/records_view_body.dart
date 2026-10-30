import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:el_karma_ph/features/employee_details_view/presentation/widgets/edit_dialogs_widget.dart';
import 'package:el_karma_ph/features/records_view/manager/cubit/records_cubit.dart';
import 'package:el_karma_ph/features/records_view/manager/cubit/records_state.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';
import 'package:el_karma_ph/features/records_view/presentation/widgets/record_card.dart';
import 'package:el_karma_ph/features/records_view/presentation/widgets/records_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RecordsViewBody extends StatelessWidget {
  const RecordsViewBody({super.key});

  Future<void> _deleteRecord(BuildContext context, RecordPreview record) async {
    final cubit = context.read<RecordsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('records.delete_title'),
      message: context.tr(
        'records.delete_message',
        args: {'period': recordPeriodLabel(context, record)},
      ),
      confirmLabel: context.tr('common.delete'),
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    final error = await cubit.deleteRecord(record);
    if (!context.mounted) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.tr(error ?? 'records.deleted')),
          backgroundColor: error == null ? Colors.green : Colors.red,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 600.0;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.015,
            ),
            child: BlocBuilder<RecordsCubit, RecordsState>(
              builder: (context, state) {
                if (state.status == RecordsStatus.loadingEmployees) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == RecordsStatus.failure &&
                    state.employees.isEmpty) {
                  return _ErrorState(
                    message: context.tr(state.message ?? 'error.generic'),
                    onRetry: () => context.read<RecordsCubit>().loadEmployees(),
                  );
                }

                if (state.employees.isEmpty) {
                  return RecordsMessage(
                    icon: Icons.people_outline_rounded,
                    text: context.tr('employees.empty'),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LabeledDropdown<String>(
                      label: context.tr('attendance.employee'),
                      hint: context.tr('records.select_employee'),
                      initialValue: state.selected?.id,
                      items: {for (final e in state.employees) e.id: e.name},
                      onChanged: (id) {
                        if (id != null) {
                          context.read<RecordsCubit>().selectEmployee(id);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _Content(
                        state: state,
                        onDeleteRecord: (record) =>
                            _deleteRecord(context, record),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, required this.onDeleteRecord});

  final RecordsState state;
  final Future<void> Function(RecordPreview record) onDeleteRecord;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RecordsCubit>();
    final employee = state.selected;

    if (employee == null) {
      return RecordsMessage(
        icon: Icons.folder_open_rounded,
        text: context.tr('records.prompt'),
      );
    }

    if (state.status == RecordsStatus.loadingRecords) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == RecordsStatus.failure) {
      return _ErrorState(
        message: context.tr(state.message ?? 'records.load_failed'),
        onRetry: () => cubit.selectEmployee(employee.id),
      );
    }

    if (state.records.isEmpty) {
      return RecordsMessage(
        icon: Icons.event_busy_outlined,
        text: context.tr('records.empty', args: {'name': employee.name}),
        hint: context.tr('records.empty_hint'),
        action: ButtonWidget(
          width: 220,
          height: 48,
          onPressed: () async {
            await GoRouter.of(context).pushNamed(AppRouter.kAttendanceView);
            cubit.refresh();
          },
          backgroundColor: kPrimaryBlue,
          foregroundColor: Colors.white,
          text: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, size: 20),
              const SizedBox(width: 6),
              Text(
                context.tr('attendance.add_record'),
                style: Styles.textStyle16,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: state.records.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final record = state.records[index];
          return RecordCard(
            record: record,
            onTap: () =>
                GoRouter.of(context)
                    .pushNamed(AppRouter.kRecordDetailsView, extra: record),
            onDelete: () => onDeleteRecord(record),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: Styles.textStyle14, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(context.tr('common.retry')),
          ),
        ],
      ),
    );
  }
}
