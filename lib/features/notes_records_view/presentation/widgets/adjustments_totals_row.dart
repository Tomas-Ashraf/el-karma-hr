import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustment_card.dart';
import 'package:flutter/material.dart';

class AdjustmentTotalsRow extends StatelessWidget {
  const AdjustmentTotalsRow({super.key, required this.items});

  final List<EmployeeAdjustment> items;

  @override
  Widget build(BuildContext context) {
    final bonus = items
        .where((e) => e.isBonus)
        .fold(0.0, (s, e) => s + e.amount);
    final ded = items
        .where((e) => !e.isBonus)
        .fold(0.0, (s, e) => s + e.amount);

    Widget chip(String label, double value, Color color) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(31),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: color)),
            const SizedBox(height: 2),
            Text(
              formatAmount(context, value),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );

    return Row(
      children: [
        chip(context.tr('notes.bonus'), bonus, kBonusColor),
        const SizedBox(width: 10),
        chip(context.tr('notes.deduction'), ded, kDeductionColor),
      ],
    );
  }
}
