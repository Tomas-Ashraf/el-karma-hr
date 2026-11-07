import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:flutter/material.dart';

String formatAmount(BuildContext context, double value) {
  final text = value % 1 == 0
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
  return '$text ${context.tr('common.egp')}';
}

class AdjustmentCard extends StatelessWidget {
  const AdjustmentCard({
    super.key,
    required this.item,
    this.showEmployee = false,
    this.onTap,
    this.onDelete,
    this.reasonLines = 2,
  });

  final EmployeeAdjustment item;
  final bool showEmployee;

  final VoidCallback? onTap;

  final VoidCallback? onDelete;

  final int reasonLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final color = item.isBonus ? kBonusColor : kDeductionColor;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: colors.outlineVariant) : null,
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 6, 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(31),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.isBonus
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showEmployee)
                        Text(
                          item.employeeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      Text(
                        item.reason,
                        maxLines: reasonLines,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: showEmployee ? 12 : 14,
                          fontWeight: showEmployee
                              ? FontWeight.w400
                              : FontWeight.w600,
                          color: showEmployee ? colors.onSurfaceVariant : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatMediumDate(context, item.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.isBonus ? '+' : '-'}'
                      '${formatAmount(context, item.amount)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr(
                        item.isBonus ? 'notes.bonus' : 'notes.deduction',
                      ),
                      style: TextStyle(fontSize: 11, color: color),
                    ),
                  ],
                ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    tooltip: context.tr('common.delete'),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 22,
                      color: kDeductionColor,
                    ),
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
