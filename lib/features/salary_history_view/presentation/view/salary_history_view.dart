import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/money_format.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/salary_history_view/manager/cubit/salary_history_cubit.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';
import 'package:el_karma_ph/features/count_salary_view/models/saved_salary_sheet.dart';
import 'package:el_karma_ph/features/count_salary_view/presentation/widgets/salary_status_chip.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustment_card.dart'
    hide formatAmount;
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/card_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SalaryHistoryView extends StatelessWidget {
  const SalaryHistoryView({super.key, required this.employee});

  final EmployeeModel employee;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SalaryHistoryCubit(employee)..load(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            '${context.tr('salary.history')} · ${employee.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              final router = GoRouter.of(context);
              router.canPop()
                  ? router.pop()
                  : router.go(AppRouter.kCountSalaryView);
            },
          ),
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: BlocBuilder<SalaryHistoryCubit, SalaryHistoryState>(
            builder: (context, state) {
              switch (state.status) {
                case SalaryHistoryStatus.loading:
                  return const Center(child: CircularProgressIndicator());

                case SalaryHistoryStatus.failure:
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
                          onPressed: () =>
                              context.read<SalaryHistoryCubit>().load(),
                          child: Text(context.tr('common.retry')),
                        ),
                      ],
                    ),
                  );

                case SalaryHistoryStatus.success:
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<SalaryHistoryCubit>().load(silent: true),
                    child: state.items.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: screenSize.height * 0.25),
                              Center(
                                child: Text(
                                  context.tr('salary.history_empty'),
                                  style: Styles.textStyle14,
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.05,
                              vertical: screenSize.height * 0.02,
                            ),
                            itemCount: state.items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) =>
                                _HistoryCard(item: state.items[i]),
                          ),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final SavedSalarySheet item;

  String _method(BuildContext context) => switch (item.paymentMethod) {
    'instapay' => context.tr('add_employee.pay_instapay'),
    'wallet' => context.tr('add_employee.pay_wallet'),
    'cash' => context.tr('add_employee.pay_cash'),
    _ => item.paymentMethod,
  };

  @override
  Widget build(BuildContext context) {
    final period =
        '${formatMediumDate(context, item.from)}  -  '
        '${formatMediumDate(context, item.to)}';

    return Container(
      decoration: cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(
            period,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                SalaryStatusChip(status: item.status),
                const Spacer(),
                Text(
                  formatAmount(context, item.net),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryBlue,
                  ),
                ),
              ],
            ),
          ),
          children: [
            _Row(
              context.tr('salary.base_salary'),
              formatAmount(context, item.baseSalary),
            ),
            _Row(
              context.tr('salary.days_attended'),
              formatDays(item.attendedDays),
            ),
            _Row(context.tr('salary.days_absent'), formatDays(item.absentDays)),
            _Row(
              context.tr('salary.line_absence'),
              '-${formatAmount(context, item.absenceDeduction)}',
              color: kDeductionColor,
            ),
            _Row(
              context.tr('salary.line_late'),
              '-${formatAmount(context, item.lateDeduction)}',
              color: kDeductionColor,
              detail: item.lateMinutes > 0
                  ? formatDuration(context, item.lateMinutes)
                  : null,
            ),
            if (item.isDelivery)
              _Row(
                context.tr('salary.line_delivery'),
                '+${formatAmount(context, item.deliveryFees)}',
                color: kBonusColor,
                detail:
                    '${item.deliveryOrders} ${context.tr('salary.orders_count')}',
              ),
            _Row(
              context.tr('notes.total_bonuses'),
              '+${formatAmount(context, item.totalBonus)}',
              color: kBonusColor,
            ),
            _Row(
              context.tr('notes.total_deductions'),
              '-${formatAmount(context, item.totalDeduction)}',
              color: kDeductionColor,
            ),
            const Divider(height: 20),
            _Row(
              context.tr('salary.net_salary'),
              formatAmount(context, item.net),
              color: kPrimaryBlue,
              bold: true,
            ),
            _Row(context.tr('add_employee.payment_method'), _method(context)),
            if (item.paidAt != null)
              _Row(
                context.tr('salary.paid_at'),
                formatDateTime(context, item.paidAt!),
              ),
            if (item.adjustments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  context.tr('salary.adjustments_title'),
                  style: Styles.textStyle16.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (final a in item.adjustments)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AdjustmentCard(item: a, reasonLines: 6),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(
    this.label,
    this.value, {
    this.color,
    this.detail,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? color;
  final String? detail;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: muted)),
                if (detail != null)
                  Text(detail!, style: TextStyle(fontSize: 11.5, color: muted)),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
