import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/notes_records_view/manager/cubit/employee_adjustments_cubit.dart';
import 'package:el_karma_ph/features/notes_records_view/manager/cubit/employee_adjustments_state.dart';
import 'package:el_karma_ph/features/notes_records_view/manager/cubit/personal_notes_state.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustment_card.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustments_totals_row.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/card_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NotesEmployeeDetailsView extends StatelessWidget {
  const NotesEmployeeDetailsView({super.key, required this.args});

  final NotesEmployeeArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmployeeAdjustmentsCubit(args)..load(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            args.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Styles.textStyle20,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              final router = GoRouter.of(context);
              router.canPop()
                  ? router.pop()
                  : router.go(AppRouter.kNotesSummaryView);
            },
          ),
        ),
        body: _Body(args: args),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.args});

  final NotesEmployeeArgs args;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final periodLabel =
        '${formatMediumDate(context, args.from)}  -  '
        '${formatMediumDate(context, args.to)}';

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child:
              BlocBuilder<EmployeeAdjustmentsCubit, EmployeeAdjustmentsState>(
                builder: (context, state) {
                  if (state.status == NotesLoadStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == NotesLoadStatus.failure) {
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
                            onPressed: () =>
                                context.read<EmployeeAdjustmentsCubit>().load(),
                            child: Text(context.tr('common.retry')),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => context
                        .read<EmployeeAdjustmentsCubit>()
                        .load(silent: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.05,
                        vertical: screenSize.height * 0.015,
                      ),
                      children: [
                        _PeriodCard(label: periodLabel),
                        const SizedBox(height: 12),
                        AdjustmentTotalsRow(items: state.items),
                        const SizedBox(height: 16),
                        if (state.items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                context.tr('notes.no_adjustments'),
                                style: Styles.textStyle14,
                              ),
                            ),
                          )
                        else
                          for (final item in state.items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              // هنا بنعرض السبب كامل تقريبًا (للعرض بس)
                              child: AdjustmentCard(item: item, reasonLines: 6),
                            ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: cardDecoration(context),
      child: Row(
        children: [
          const Icon(Icons.date_range_rounded, color: kPrimaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
