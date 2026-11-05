import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/notes_records_view/manager/cubit/notes_summary_cubit.dart';
import 'package:el_karma_ph/features/notes_records_view/manager/cubit/notes_summary_state.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustment_card.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/card_decoration.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/employee_row.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/notes_period_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NotesSummaryView extends StatelessWidget {
  const NotesSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotesSummaryCubit()..loadEmployees(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            context.tr('notes.summary_title'),
            style: Styles.textStyle20,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              final router = GoRouter.of(context);
              router.canPop()
                  ? router.pop()
                  : router.go(AppRouter.kNotesRecordsView);
            },
          ),
        ),
        body: const _SummaryBody(),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody();

  Future<void> _openPeriod(BuildContext context) async {
    final cubit = context.read<NotesSummaryCubit>();
    final state = cubit.state;
    if (state.employees.isEmpty) return;

    final result = await showNotesPeriodDialog(context, initial: state.period);
    if (result != null) cubit.calculate(result);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BlocConsumer<NotesSummaryCubit, NotesSummaryState>(
      // أول ما الموظفين يتحملوا نطلب الفترة
      listenWhen: (previous, current) =>
          previous.status == NotesSummaryStatus.loadingEmployees &&
          current.status == NotesSummaryStatus.ready,
      listener: (context, state) => _openPeriod(context),
      builder: (context, state) {
        final period = state.period;
        final label = period == null
            ? context.tr('notes.select_period')
            : '${formatMediumDate(context, period.from)}  -  '
                  '${formatMediumDate(context, period.to)}';

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
                    _PeriodButton(
                      label: label,
                      onTap: state.employees.isEmpty
                          ? null
                          : () => _openPeriod(context),
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

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final NotesSummaryState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotesSummaryCubit>();
    final period = state.period;

    switch (state.status) {
      case NotesSummaryStatus.loadingEmployees:
      case NotesSummaryStatus.calculating:
        return const Center(child: CircularProgressIndicator());

      case NotesSummaryStatus.failure:
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
                onPressed: () => period == null
                    ? cubit.loadEmployees()
                    : cubit.calculate(period),
                child: Text(context.tr('common.retry')),
              ),
            ],
          ),
        );

      case NotesSummaryStatus.ready:
        return _Message(
          icon: state.employees.isEmpty
              ? Icons.people_outline_rounded
              : Icons.bar_chart_rounded,
          text: context.tr(
            state.employees.isEmpty
                ? 'employees.empty'
                : 'notes.summary_prompt',
          ),
        );

      case NotesSummaryStatus.success:
        final summary = state.summary;
        if (summary == null || summary.employees.isEmpty) {
          return _Message(
            icon: Icons.inbox_outlined,
            text: context.tr('notes.summary_empty'),
          );
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.arrow_upward_rounded,
                    label: context.tr('notes.total_bonuses'),
                    value: formatAmount(context, summary.totalBonus),
                    color: kBonusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.arrow_downward_rounded,
                    label: context.tr('notes.total_deductions'),
                    value: formatAmount(context, summary.totalDeduction),
                    color: kDeductionColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('notes.by_employee'),
              style: Styles.textStyle16.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final e in summary.employees)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: EmployeeRow(
                  name: e.name,
                  bonus: e.bonus,
                  deduction: e.deduction,
                ),
              ),
          ],
        );
    }
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withAlpha(31),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
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
