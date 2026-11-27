import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/money_format.dart';
import 'package:el_karma_ph/core/utils/send_money.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/count_salary_view/manager/cubit/salary_sheet_cubit.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/section_tile_widget.dart';
import 'package:el_karma_ph/features/employee_details_view/presentation/widgets/edit_dialogs_widget.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/card_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentSection extends StatelessWidget {
  const PaymentSection({super.key, required this.sheet});

  final SalarySheet sheet;

  String _methodLabel(BuildContext context, String method) => switch (method) {
    'instapay' => context.tr('add_employee.pay_instapay'),
    'wallet' => context.tr('add_employee.pay_wallet'),
    'cash' => context.tr('add_employee.pay_cash'),
    _ => method,
  };

  Future<void> _copy(BuildContext context, String value) async {
    final messenger = ScaffoldMessenger.of(context);
    final text = context.tr('salary.copied');
    await Clipboard.setData(ClipboardData(text: value));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
      );
  }

  Future<void> _markPaid(BuildContext context) async {
    final cubit = context.read<SalarySheetCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('salary.paid_confirm_title'),
      message: context.tr(
        'salary.paid_confirm_message',
        args: {
          'amount': formatAmount(context, sheet.net),
          'name': sheet.employee.name,
        },
      ),
      confirmLabel: context.tr('common.confirm'),
    );
    if (confirmed != true || !context.mounted) return;

    final error = await cubit.markPaid();
    if (!context.mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.tr(error ?? 'salary.paid_success')),
          backgroundColor: error == null ? Colors.green : Colors.red,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final method = sheet.employee.paymentMethod;
    final isCash = method == 'cash';
    final phone = localMobile(sheet.employee.phoneNumber);
    final saving = context.select((SalarySheetCubit c) => c.state.saving);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitleWidget(context.tr('salary.payment_title')),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoRow(
                label: context.tr('add_employee.payment_method'),
                value: _methodLabel(context, method),
              ),
              if (isCash) ...[
                const SizedBox(height: 10),
                Text(context.tr('salary.cash_hint'), style: Styles.textStyle14),
              ] else ...[
                const SizedBox(height: 10),
                _CopyRow(
                  label: context.tr('salary.mobile'),
                  value: phone.isEmpty ? '—' : phone,
                  onCopy: phone.isEmpty ? null : () => _copy(context, phone),
                ),
              ],
              const SizedBox(height: 10),
              _CopyRow(
                label: context.tr('salary.net_salary'),
                value: formatAmount(context, sheet.net),
                onCopy: () => _copy(context, plainAmount(sheet.net)),
              ),
              const SizedBox(height: 14),
              if (sheet.isPaid)
                Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kBonusColor.withAlpha(31),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: kBonusColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('salary.paid_done'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: kBonusColor,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ButtonWidget(
                  width: double.infinity,
                  height: 48,
                  onPressed: saving ? null : () => _markPaid(context),
                  backgroundColor: kBonusColor,
                  foregroundColor: Colors.white,
                  text: saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          context.tr('salary.mark_paid'),
                          style: Styles.textStyle16,
                        ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 14, end: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onCopy,
            tooltip: context.tr('salary.copy'),
            icon: const Icon(Icons.copy_rounded, size: 20, color: kPrimaryBlue),
          ),
        ],
      ),
    );
  }
}
