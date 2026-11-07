import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/employee_details_view/presentation/widgets/edit_dialogs_widget.dart';
import 'package:el_karma_ph/features/notes_records_view/manager/cubit/employee_notes_cubit.dart';
import 'package:el_karma_ph/features/notes_records_view/manager/cubit/employee_notes_state.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/add_adjustment_dialog.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustment_card.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustments_totals_row.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/notes_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeNotesTab extends StatefulWidget {
  const EmployeeNotesTab({super.key});

  @override
  State<EmployeeNotesTab> createState() => _EmployeeNotesTabState();
}

class _EmployeeNotesTabState extends State<EmployeeNotesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (_) => EmployeeNotesCubit()..loadEmployees(),
      child: const _EmployeeNotesView(),
    );
  }
}

class _EmployeeNotesView extends StatelessWidget {
  const _EmployeeNotesView();

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
    final cubit = context.read<EmployeeNotesCubit>();
    final state = cubit.state;
    if (state.employees.isEmpty) return;

    final result = await showNotesFilterDialog(
      context,
      employees: state.employees,
      initial: state.filter,
    );
    if (result != null) cubit.applyFilter(result);
  }

  Future<void> _openAdd(BuildContext context) async {
    final cubit = context.read<EmployeeNotesCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final state = cubit.state;
    if (state.employees.isEmpty) return;

    final draft = await showAdjustmentDialog(
      context,
      employees: [...state.employees],
    );

    if (draft == null) return;

    final error = await cubit.addAdjustment(draft);
    if (!context.mounted) return;
    _snack(messenger, context.tr(error ?? 'notes.added'), error == null);
  }

  Future<void> _delete(BuildContext context, EmployeeAdjustment item) async {
    final cubit = context.read<EmployeeNotesCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('notes.delete_adjustment_title'),
      message: context.tr(
        'notes.delete_adjustment_message',
        args: {
          'type': context.tr(item.isBonus ? 'notes.bonus' : 'notes.deduction'),
          'amount': formatAmount(context, item.amount),
        },
      ),
      confirmLabel: context.tr('common.delete'),
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    final error = await cubit.deleteAdjustment(item);
    if (!context.mounted) return;
    _snack(messenger, context.tr(error ?? 'notes.deleted'), error == null);
  }

  Future<void> _openEdit(BuildContext context, EmployeeAdjustment item) async {
    final cubit = context.read<EmployeeNotesCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final employee = cubit.state.filter?.employee;
    if (employee == null) return;

    final draft = await showAdjustmentDialog(
      context,
      employees: cubit.state.employees,
      initialEmployee: employee,
      initial: item,
    );
    if (draft == null) return;

    final error = await cubit.updateAdjustment(item, draft);
    if (!context.mounted) return;
    _snack(messenger, context.tr(error ?? 'notes.updated'), error == null);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BlocConsumer<EmployeeNotesCubit, EmployeeNotesState>(
      listenWhen: (previous, current) =>
          previous.status == EmployeeNotesStatus.loadingEmployees &&
          current.status == EmployeeNotesStatus.ready,
      listener: (context, state) => _openFilter(context),
      builder: (context, state) {
        final filter = state.filter;
        final label = filter == null
            ? context.tr('attendance.select_period')
            : '${filter.employee.name}  •  '
                  '${formatMediumDate(context, filter.from)}'
                  ' - ${formatMediumDate(context, filter.to)}';
        final canAdd = state.employees.isNotEmpty;

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
                      onTap: canAdd ? () => _openFilter(context) : null,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _Content(
                        state: state,
                        onEdit: (item) => _openEdit(context, item),
                        onDelete: (item) => _delete(context, item),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ButtonWidget(
                      width: double.infinity,
                      height: 52,
                      onPressed: canAdd ? () => _openAdd(context) : null,
                      backgroundColor: kPrimaryBlue,
                      foregroundColor: Colors.white,
                      text: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_rounded, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            context.tr('notes.add_adjustment'),
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
    required this.onDelete,
    required this.onEdit,
  });

  final EmployeeNotesState state;
  final void Function(EmployeeAdjustment item) onDelete;
  final void Function(EmployeeAdjustment item) onEdit;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EmployeeNotesCubit>();
    final filter = state.filter;

    switch (state.status) {
      case EmployeeNotesStatus.loadingEmployees:
      case EmployeeNotesStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case EmployeeNotesStatus.failure:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr(state.message ?? 'notes.load_failed'),
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

      case EmployeeNotesStatus.ready:
        return state.employees.isEmpty
            ? _Message(
                icon: Icons.people_outline_rounded,
                text: context.tr('employees.empty'),
              )
            : _Message(
                icon: Icons.manage_search_rounded,
                text: context.tr('notes.prompt'),
              );

      case EmployeeNotesStatus.success:
        if (state.items.isEmpty) {
          return _Message(
            icon: Icons.inbox_outlined,
            text: context.tr('notes.no_adjustments'),
            hint: filter == null
                ? null
                : context.tr(
                    'notes.no_adjustments_hint',
                    args: {'name': filter.employee.name},
                  ),
          );
        }
        return Column(
          children: [
            AdjustmentTotalsRow(items: state.items),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => AdjustmentCard(
                  item: state.items[i],
                  onTap: () => onEdit(state.items[i]),
                  onDelete: () => onDelete(state.items[i]),
                ),
              ),
            ),
          ],
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
