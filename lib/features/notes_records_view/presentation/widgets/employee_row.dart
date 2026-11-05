import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/initials_avatar.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustment_card.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/card_decoration.dart';
import 'package:flutter/material.dart';

class EmployeeRow extends StatelessWidget {
  const EmployeeRow({
    super.key,
    required this.name,
    required this.bonus,
    required this.deduction,
  });

  final String name;
  final double bonus;
  final double deduction;

  String get _initials {
    final letters = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join()
        .toUpperCase();
    return letters.isEmpty ? '?' : letters;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: cardDecoration(context),
      child: Row(
        children: [
          InitialsAvatar(initials: _initials, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${formatAmount(context, bonus)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kBonusColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '-${formatAmount(context, deduction)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kDeductionColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
