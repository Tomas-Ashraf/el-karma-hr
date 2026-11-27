import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/money_format.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';

enum SalaryRowTone { base, add, subtract }

/// القيمة اللي الصف ده بيمثلها (بتتعدل لما صاحب الصيدلية يدوس Edit).
enum SalaryField {
  baseSalary,
  absentDays,
  lateDeduction,
  deliveryOrders,
  bonus,
  deduction,
}

class SalaryBreakdownRow {
  const SalaryBreakdownRow({
    required this.field,
    required this.title,
    required this.amount,
    required this.tone,
    this.detail,
  });

  final SalaryField field;
  final String title;
  final String? detail;
  final double amount;
  final SalaryRowTone tone;
}

/// [includeEmpty] = true بيعرض كل الصفوف حتى لو قيمتها صفر (للشاشة، علشان
/// أي قيمة تتعدل). الـ PDF بيسيبها false فمبيعرضش الصفوف الفاضية.
List<SalaryBreakdownRow> buildBreakdown(
  AppLocalizations l10n,
  SalarySheet sheet, {
  bool includeEmpty = false,
}) {
  final rows = <SalaryBreakdownRow>[];

  void add(SalaryBreakdownRow row, {bool always = false}) {
    if (always || includeEmpty || row.amount > 0) rows.add(row);
  }

  add(
    SalaryBreakdownRow(
      field: SalaryField.baseSalary,
      title: l10n.translate('salary.base_salary'),
      detail:
          '${l10n.translate('salary.daily_rate')}: '
          '${formatAmountOf(l10n, sheet.dailyRate)}',
      amount: sheet.baseSalary,
      tone: SalaryRowTone.base,
    ),
    always: true,
  );

  add(
    SalaryBreakdownRow(
      field: SalaryField.absentDays,
      title: l10n.translate('salary.line_absence'),
      detail: l10n.translate(
        'salary.earned_detail',
        args: {
          'days': formatDays(sheet.absentDays),
          'rate': formatAmountOf(l10n, sheet.dailyRate),
        },
      ),
      amount: sheet.absenceDeduction,
      tone: SalaryRowTone.subtract,
    ),
  );

  final lateMatchesMinutes =
      sheet.lateDeduction ==
      roundMoney(sheet.lateMinutes * sheet.deductionPerMinute);
  add(
    SalaryBreakdownRow(
      field: SalaryField.lateDeduction,
      title: l10n.translate('salary.line_late'),
      // لو القيمة اتعدلت يدويًا مبنعرضش التفصيل عشان ميبقاش مضلل
      detail: lateMatchesMinutes && sheet.lateMinutes > 0
          ? l10n.translate(
              'salary.line_late_detail',
              args: {
                'time': formatMinutes(l10n, sheet.lateMinutes),
                'rate': formatAmountOf(l10n, sheet.deductionPerMinute),
              },
            )
          : null,
      amount: sheet.lateDeduction,
      tone: SalaryRowTone.subtract,
    ),
  );

  if (sheet.isDelivery) {
    add(
      SalaryBreakdownRow(
        field: SalaryField.deliveryOrders,
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

  add(
    SalaryBreakdownRow(
      field: SalaryField.bonus,
      title: l10n.translate('notes.total_bonuses'),
      amount: sheet.totalBonus,
      tone: SalaryRowTone.add,
    ),
  );
  add(
    SalaryBreakdownRow(
      field: SalaryField.deduction,
      title: l10n.translate('notes.total_deductions'),
      amount: sheet.totalDeduction,
      tone: SalaryRowTone.subtract,
    ),
  );
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
