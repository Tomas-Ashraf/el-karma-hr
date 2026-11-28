import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/attendance_exception_view/manager/cubit/attendance_exception_cubit.dart';
import 'package:el_karma_ph/features/attendance_exception_view/manager/cubit/attendance_exception_state.dart';
import 'package:el_karma_ph/features/attendance_exception_view/models/attendance_exception_models.dart';
import 'package:el_karma_ph/features/attendance_exception_view/presentation/widgets/exception_card.dart';
import 'package:el_karma_ph/features/attendance_exception_view/presentation/widgets/exception_editor_dialog.dart';
import 'package:el_karma_ph/features/attendance_exception_view/presentation/widgets/exception_filter_dialog.dart';
import 'package:el_karma_ph/features/employee_details_view/presentation/widgets/edit_dialogs_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceExceptionViewBody extends StatelessWidget {
  const AttendanceExceptionViewBody({super.key});

  void _snack(ScaffoldMessengerState messenger, String text, bool ok) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
  }

  Future<void> _openFilter(BuildContext context) async {
    final cubit = context.read<AttendanceExceptionCubit>();
    final state = cubit.state;
    if (state.employees.isEmpty) return;

    final result = await showExceptionsFilterDialog(
      context,
      employees: state.employees,
      initial: state.filter,
    );
    if (result != null) cubit.applyFilter(result);
  }

  Future<void> _openEditor(
    BuildContext context, [
    AttendanceException? item,
  ]) async {
    final cubit = context.read<AttendanceExceptionCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final filter = cubit.state.filter;
    if (filter == null) return;

    final result = await showExceptionEditorDialog(
      context,
      employeeId: filter.employee.id,
      initial: item,
    );
    if (result == null) return;

    final error = item == null
        ? await cubit.add(result)
        : await cubit.update(result);
    if (!context.mounted) return;
    _snack(
      messenger,
      context.tr(
        error ?? (item == null ? 'exceptions.added' : 'exceptions.updated'),
      ),
      error == null,
    );
  }

  Future<void> _delete(BuildContext context, AttendanceException item) async {
    final cubit = context.read<AttendanceExceptionCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('exceptions.delete_title'),
      message: context.tr('exceptions.delete_message'),
      confirmLabel: context.tr('common.delete'),
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    final error = await cubit.delete(item);
    if (!context.mounted) return;
    _snack(messenger, context.tr(error ?? 'exceptions.deleted'), error == null);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BlocConsumer<AttendanceExceptionCubit, AttendanceExceptionState>(
      listenWhen: (previous, current) =>
          previous.status == ExceptionsStatus.loadingEmployees &&
          current.status == ExceptionsStatus.ready,
      listener: (context, state) => _openFilter(context),
      builder: (context, state) {
        final filter = state.filter;
        final label = filter == null
            ? context.tr('attendance.select_period')
            : '${filter.employee.name}  •  '
                  '${formatMediumDate(context, filter.from)}'
                  ' - ${formatMediumDate(context, filter.to)}';

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05,
                  vertical: screenSize.height * 0.015,
                ),
                child: Column(
                  children: [
                    _FilterButton(
                      label: label,
                      onTap: state.employees.isEmpty
                          ? null
                          : () => _openFilter(context),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _Content(
                        state: state,
                        onEdit: (item) => _openEditor(context, item),
                        onDelete: (item) => _delete(context, item),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ButtonWidget(
                      width: double.infinity,
                      height: 52,
                      onPressed: filter == null
                          ? null
                          : () => _openEditor(context),
                      backgroundColor: kPrimaryBlue,
                      foregroundColor: Colors.white,
                      text: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_rounded, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            context.tr('exceptions.add'),
                            style: Styles.textStyle16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
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

class _Content extends StatelessWidget {
  const _Content({
    required this.state,
    required this.onEdit,
    required this.onDelete,
  });

  final AttendanceExceptionState state;
  final void Function(AttendanceException item) onEdit;
  final void Function(AttendanceException item) onDelete;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AttendanceExceptionCubit>();
    final filter = state.filter;

    switch (state.status) {
      case ExceptionsStatus.loadingEmployees:
      case ExceptionsStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case ExceptionsStatus.failure:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr(state.message ?? 'exceptions.load_failed'),
                style: Styles.textStyle14,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => filter == null
                    ? cubit.loadEmployees()
                    : cubit.applyFilter(filter),
                child: Text(context.tr('common.retry')),
              ),
            ],
          ),
        );

      case ExceptionsStatus.ready:
        return state.employees.isEmpty
            ? _Message(
                icon: Icons.people_outline_rounded,
                text: context.tr('employees.empty'),
              )
            : _Message(
                icon: Icons.manage_search_rounded,
                text: context.tr('exceptions.prompt'),
              );

      case ExceptionsStatus.success:
        if (state.items.isEmpty) {
          return _Message(
            icon: Icons.event_available_outlined,
            text: context.tr('exceptions.empty'),
            hint: filter == null
                ? null
                : context.tr(
                    'exceptions.empty_hint',
                    args: {'name': filter.employee.name},
                  ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            if (filter != null) await cubit.applyFilter(filter);
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: state.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) => ExceptionCard(
              item: state.items[i],
              onTap: () => onEdit(state.items[i]),
              onDelete: () => onDelete(state.items[i]),
            ),
          ),
        );
    }
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.label, required this.onTap});

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
              const Icon(Icons.person_search_rounded, color: kPrimaryBlue),
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

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.hint});

  final IconData icon;
  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final h = hint;
    return Center(
      child: SingleChildScrollView(
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
            Text(text, style: Styles.textStyle16, textAlign: TextAlign.center),
            if (h != null) ...[
              const SizedBox(height: 6),
              Text(h, style: Styles.textStyle14, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
