import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustment_card.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/card_decoration.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/employee_row.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotesSummaryView extends StatelessWidget {
  const NotesSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final data = dummyAdjustments;

    final bonus = data
        .where((e) => e.isBonus)
        .fold(0.0, (s, e) => s + e.amount);
    final ded = data.where((e) => !e.isBonus).fold(0.0, (s, e) => s + e.amount);
    final net = bonus - ded;

    final perEmployee = <String, ({double bonus, double ded})>{};
    for (final a in data) {
      final cur = perEmployee[a.employeeName] ?? (bonus: 0.0, ded: 0.0);
      perEmployee[a.employeeName] = a.isBonus
          ? (bonus: cur.bonus + a.amount, ded: cur.ded)
          : (bonus: cur.bonus, ded: cur.ded + a.amount);
    }

    return Scaffold(
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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.02,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: Icons.arrow_upward_rounded,
                        label: context.tr('notes.total_bonuses'),
                        value: formatAmount(context, bonus),
                        color: kBonusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.arrow_downward_rounded,
                        label: context.tr('notes.total_deductions'),
                        value: formatAmount(context, ded),
                        color: kDeductionColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _StatTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: context.tr('notes.net'),
                  value:
                      '${net >= 0 ? '+' : '-'}${formatAmount(context, net.abs())}',
                  color: kPrimaryBlue,
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr('notes.by_employee'),
                  style: Styles.textStyle16.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                for (final entry in perEmployee.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EmployeeRow(
                      name: entry.key,
                      bonus: entry.value.bonus,
                      deduction: entry.value.ded,
                    ),
                  ),
              ],
            ),
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
