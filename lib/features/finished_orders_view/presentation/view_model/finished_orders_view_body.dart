import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/finished_orders_view/manager/cubit/finished_orders_cubit.dart';
import 'package:el_karma_ph/features/finished_orders_view/manager/cubit/finished_orders_state.dart';
import 'package:el_karma_ph/features/finished_orders_view/presentation/widgets/finished_order_card.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/notes_period_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinishedOrdersViewBody extends StatefulWidget {
  const FinishedOrdersViewBody({super.key});

  @override
  State<FinishedOrdersViewBody> createState() => _FinishedOrdersViewBodyState();
}

class _FinishedOrdersViewBodyState extends State<FinishedOrdersViewBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openPeriod();
    });
  }

  Future<void> _openPeriod() async {
    final cubit = context.read<FinishedOrdersCubit>();
    final result = await showNotesPeriodDialog(
      context,
      initial: cubit.state.period,
    );
    if (result != null) cubit.loadPeriod(result);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.015,
            ),
            child: BlocBuilder<FinishedOrdersCubit, FinishedOrdersState>(
              builder: (context, state) {
                final period = state.period;
                final label = period == null
                    ? context.tr('notes.select_period')
                    : '${formatMediumDate(context, period.from)}  -  '
                          '${formatMediumDate(context, period.to)}';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PeriodButton(label: label, onTap: _openPeriod),
                    const SizedBox(height: 12),
                    Expanded(child: _Content(state: state)),
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
  const _Content({required this.state});

  final FinishedOrdersState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FinishedOrdersCubit>();

    switch (state.status) {
      case FinishedOrdersStatus.ready:
        return _Message(
          icon: Icons.date_range_rounded,
          text: context.tr('orders.finished_prompt'),
        );

      case FinishedOrdersStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case FinishedOrdersStatus.failure:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr(state.message ?? 'orders.load_finished_failed'),
                style: Styles.textStyle14,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  final period = state.period;
                  if (period != null) cubit.loadPeriod(period);
                },
                child: Text(context.tr('common.retry')),
              ),
            ],
          ),
        );

      case FinishedOrdersStatus.success:
        final visible = state.visible;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FilterBar(selected: state.filter),
            const SizedBox(height: 12),
            Text(
              context.tr('orders.count', args: {'count': '${visible.length}'}),
              style: Styles.textStyle14,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: cubit.refresh,
                child: visible.isEmpty
                    ? const _Empty()
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            FinishedOrderCard(order: visible[index]),
                      ),
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
  final VoidCallback onTap;

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

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected});

  final FinishedOrdersFilter selected;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FinishedOrdersCubit>();
    final items = <(FinishedOrdersFilter, String)>[
      (FinishedOrdersFilter.all, context.tr('orders.filter_all')),
      (FinishedOrdersFilter.success, context.tr('orders.status_success')),
      (FinishedOrdersFilter.failed, context.tr('orders.status_failed')),
    ];

    return Wrap(
      spacing: 8,
      children: [
        for (final (filter, label) in items)
          ChoiceChip(
            label: Text(label),
            selected: selected == filter,
            onSelected: (_) => cubit.setFilter(filter),
            selectedColor: kPrimaryBlue.withAlpha(31),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected == filter
                  ? kPrimaryBlue
                  : context.colors.onSurfaceVariant,
            ),
            side: BorderSide(
              color: selected == filter
                  ? kPrimaryBlue
                  : context.colors.outlineVariant,
            ),
            showCheckmark: false,
          ),
      ],
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

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.12),
        Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: kPrimaryBlue.withAlpha(31),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.task_alt_outlined,
                  size: 34,
                  color: kPrimaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('orders.finished_empty'),
                style: Styles.textStyle14,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
