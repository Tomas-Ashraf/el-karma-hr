import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/money_format.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';

enum SalaryRowTone { base, add, subtract }

class SalaryBreakdownRow {
  const SalaryBreakdownRow({
    required this.title,
    required this.amount,
    required this.tone,
    this.detail,
  });

  final String title;
  final String? detail;
  final double amount;
  final SalaryRowTone tone;
}

List<SalaryBreakdownRow> buildBreakdown(
  AppLocalizations l10n,
  SalarySheet sheet,
) {
  final rows = <SalaryBreakdownRow>[];

  if (sheet.isDelivery) {
    rows.add(
      SalaryBreakdownRow(
        title: l10n.translate('salary.base_salary'),
        amount: sheet.baseSalary,
        tone: SalaryRowTone.base,
      ),
    );
    if (sheet.deliveryOrders > 0) {
      rows.add(
        SalaryBreakdownRow(
          title: l10n.translate('salary.line_delivery'),
          detail: l10n.translate(
            'salary.line_delivery_detail',
            args: {
              'count': '${sheet.deliveryOrders}',
              'fee': formatAmountOf(l10n, kDeliveryFeePerOrder),
            },
          ),
          amount: sheet.deliveryFees,
          tone: SalaryRowTone.add,
        ),
      );
    }
  } else {
    final parts = [
      l10n.translate(
        'salary.earned_detail',
        args: {
          'days': formatDays(sheet.paidDays),
          'rate': formatAmountOf(l10n, sheet.dailyRate),
        },
      ),
      if (sheet.offDays > 0)
        l10n.translate(
          'salary.days_split',
          args: {
            'attended': formatDays(sheet.attendedDays),
            'off': '${sheet.offDays}',
          },
        ),
    ];
    rows.add(
      SalaryBreakdownRow(
        title: l10n.translate('salary.earned_salary'),
        detail: parts.join('\n'),
        amount: sheet.earnedSalary,
        tone: SalaryRowTone.base,
      ),
    );
    if (sheet.lateDeduction > 0) {
      rows.add(
        SalaryBreakdownRow(
          title: l10n.translate('salary.line_late'),
          detail: l10n.translate(
            'salary.line_late_detail',
            args: {
              'time': formatMinutes(l10n, sheet.lateMinutes),
              'rate': formatAmountOf(l10n, sheet.deductionPerMinute),
            },
          ),
          amount: sheet.lateDeduction,
          tone: SalaryRowTone.subtract,
        ),
      );
    }
  }

  if (sheet.totalBonus > 0) {
    rows.add(
      SalaryBreakdownRow(
        title: l10n.translate('notes.total_bonuses'),
        amount: sheet.totalBonus,
        tone: SalaryRowTone.add,
      ),
    );
  }
  if (sheet.totalDeduction > 0) {
    rows.add(
      SalaryBreakdownRow(
        title: l10n.translate('notes.total_deductions'),
        amount: sheet.totalDeduction,
        tone: SalaryRowTone.subtract,
      ),
    );
  }
  return rows;
}

String signedAmount(AppLocalizations l10n, SalaryBreakdownRow row) {
  final text = formatAmountOf(l10n, row.amount);
  switch (row.tone) {
    case SalaryRowTone.base:
      return text;
    case SalaryRowTone.add:
      return '+$text';
    case SalaryRowTone.subtract:
      return '-$text';
  }
}
