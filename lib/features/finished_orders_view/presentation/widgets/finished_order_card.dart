import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/finished_orders_view/models/finished_order.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustment_card.dart'
    show formatAmount;
import 'package:flutter/material.dart';

class FinishedOrderCard extends StatelessWidget {
  const FinishedOrderCard({super.key, required this.order});

  final FinishedOrder order;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final accent = order.isSuccess ? kBonusColor : kDeductionColor;
    final muted = TextStyle(fontSize: 12, color: colors.onSurfaceVariant);

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withAlpha(31),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  order.isSuccess
                      ? Icons.check_circle_outline_rounded
                      : Icons.cancel_outlined,
                  size: 22,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.reference,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _IconLine(
                      icon: Icons.motorcycle_rounded,
                      text: order.deliveryMan,
                      style: muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _Chip(
                text: context.tr(
                  order.isSuccess
                      ? 'orders.status_success'
                      : 'orders.status_failed',
                ),
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AmountRow(
            label: context.tr('orders.expected_amount'),
            value: formatAmount(context, order.amount),
          ),
          if (order.isSuccess && order.returnedAmount != null) ...[
            const SizedBox(height: 6),
            _AmountRow(
              label: context.tr('orders.returned_amount_title'),
              value: formatAmount(context, order.returnedAmount!),
              valueColor: order.amountMatched == false ? warning : null,
            ),
            if (order.amountMatched == false) ...[
              const SizedBox(height: 6),
              _Chip(
                text: context.tr('orders.amount_not_matched'),
                color: warning,
              ),
            ],
          ],
          if (!order.isSuccess && order.failureReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${context.tr('orders.failure_title')}: ${order.failureReason}',
              style: TextStyle(fontSize: 13, color: colors.onSurface),
            ),
          ],
          const SizedBox(height: 10),
          Divider(height: 1, color: colors.outlineVariant),
          const SizedBox(height: 10),
          if (order.createdAt != null)
            _IconLine(
              icon: Icons.add_circle_outline_rounded,
              text:
                  '${context.tr('orders.created_at')}: '
                  '${formatDateTime(context, order.createdAt!)}',
              style: muted,
            ),
          if (order.finishedAt != null) ...[
            const SizedBox(height: 3),
            _IconLine(
              icon: Icons.flag_outlined,
              text:
                  '${context.tr('orders.finished_at')}: '
                  '${formatDateTime(context, order.finishedAt!)}',
              style: muted,
            ),
          ],
          if ((order.finishedByName ?? '').isNotEmpty) ...[
            const SizedBox(height: 3),
            _IconLine(
              icon: Icons.person_outline_rounded,
              text: order.finishedByName!,
              style: muted,
            ),
          ],
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({
    required this.icon,
    required this.text,
    required this.style,
  });

  final IconData icon;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: style.color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
