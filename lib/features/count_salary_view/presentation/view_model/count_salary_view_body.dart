import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/count_salary_view/manager/cubit/count_salary_cubit.dart';
import 'package:el_karma_ph/features/count_salary_view/manager/cubit/count_salary_state.dart';
import 'package:el_karma_ph/features/count_salary_view/presentation/widgets/salary_employee_dialog.dart';
import 'package:el_karma_ph/features/count_salary_view/presentation/widgets/salary_header_card.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';
import 'package:el_karma_ph/features/records_view/presentation/widgets/record_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CountSalaryViewBody extends StatelessWidget {
  const CountSalaryViewBody({super.key});

  Future<void> _pickEmployee(BuildContext context) async {
    final cubit = context.read<CountSalaryCubit>();
    final state = cubit.state;
    if (state.employees.isEmpty) return;

    final result = await showSalaryEmployeeDialog(
      context,
      employees: state.employees,
      initial: state.selected,
    );
    if (result != null) cubit.selectEmployee(result.id);
  }

  Future<void> _openSheet(BuildContext context, RecordPreview record) async {
    final cubit = context.read<CountSalaryCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final result = await cubit.calculate(record);

    final sheet = result.sheet;
    if (sheet != null) {
      router.pushNamed(AppRouter.kSalarySheetView, extra: sheet);
      return;
    }
    final error = result.error;
    if (error != null && context.mounted) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.tr(error)),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 600.0;

    return BlocConsumer<CountSalaryCubit, CountSalaryState>(
      listenWhen: (previous, current) =>
          previous.status == CountSalaryStatus.loadingEmployees &&
          current.status == CountSalaryStatus.ready,
      listener: (context, state) => _pickEmployee(context),
      builder: (context, state) {
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EmployeeButton(
                      label:
                          state.selected?.name ??
                          context.tr('salary.select_employee'),
                      onTap: state.employees.isEmpty
                          ? null
                          : () => _pickEmployee(context),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Stack(
                        children: [
                          _Content(
                            state: state,
                            onOpen: (r) => _openSheet(context, r),
                          ),
                          if (state.isCalculating)
                            Positioned.fill(
                              child: ColoredBox(
                                color: context.colors.surface.withAlpha(180),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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
  const _Content({required this.state, required this.onOpen});

  final CountSalaryState state;
  final void Function(RecordPreview record) onOpen;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CountSalaryCubit>();
    final employee = state.selected;

    switch (state.status) {
      case CountSalaryStatus.loadingEmployees:
      case CountSalaryStatus.loadingRecords:
        return const Center(child: CircularProgressIndicator());

      case CountSalaryStatus.failure:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr(state.message ?? 'error.generic'),
                style: Styles.textStyle14,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => employee == null
                    ? cubit.loadEmployees()
                    : cubit.selectEmployee(employee.id),
                child: Text(context.tr('common.retry')),
              ),
            ],
          ),
        );

      case CountSalaryStatus.ready:
        return _Message(
          icon: state.employees.isEmpty
              ? Icons.people_outline_rounded
              : Icons.payments_outlined,
          text: context.tr(
            state.employees.isEmpty ? 'employees.empty' : 'salary.prompt',
          ),
        );

      case CountSalaryStatus.success:
        if (employee == null) return const SizedBox.shrink();
        return ListView(
          padding: const EdgeInsets.only(bottom: 8),
          children: [
            SalaryHeaderCard(employee: employee),
            const SizedBox(height: 16),
            if (state.records.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: _Message(
                  icon: Icons.event_busy_outlined,
                  text: context.tr(
                    'records.empty',
                    args: {'name': employee.name},
                  ),
                ),
              )
            else ...[
              Text(
                context.tr(
                  'salary.records_count',
                  args: {'count': '${state.records.length}'},
                ),
                style: Styles.textStyle14,
              ),
              const SizedBox(height: 2),
              Text(context.tr('salary.tap_hint'), style: Styles.textStyle14),
              const SizedBox(height: 12),
              for (final record in state.records)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RecordCard(
                    record: record,
                    onTap: () => onOpen(record),
                  ),
                ),
            ],
          ],
        );
    }
  }
}

class _EmployeeButton extends StatelessWidget {
  const _EmployeeButton({required this.label, required this.onTap});

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
