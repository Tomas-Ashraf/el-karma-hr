import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/employee_jobs.dart';
import 'package:el_karma_ph/core/utils/money_format.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_breakdown.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';
import 'package:el_karma_ph/features/count_salary_view/presentation/pdf/salary_pdf_builder.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/widgets/section_tile_widget.dart';
import 'package:el_karma_ph/features/employee_details_view/presentation/widgets/edit_dialogs_widget.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustment_card.dart'
    hide formatAmount;
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/card_decoration.dart';
import 'package:el_karma_ph/features/record_details_view/presentation/pdf/pdf_export_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SalarySheetViewBody extends StatefulWidget {
  const SalarySheetViewBody({super.key, required this.sheet});

  final SalarySheet sheet;

  @override
  State<SalarySheetViewBody> createState() => _SalarySheetViewBodyState();
}

class _SalarySheetViewBodyState extends State<SalarySheetViewBody> {
  late SalarySheet _sheet = widget.sheet;

  static String _plain(double v) => v % 1 == 0 ? '${v.toInt()}' : '$v';

  String? _validate(String? v) {
    final n = double.tryParse((v ?? '').trim());
    if (n == null || n < 0) return context.tr('settings.invalid_amount');
    return null;
  }

  Future<void> _edit(SalaryField field) async {
    final egp = context.tr('common.egp');
    final (
      String label,
      double current,
      String? suffix,
      bool integer,
    ) = switch (field) {
      SalaryField.baseSalary => (
        context.tr('salary.base_salary'),
        _sheet.baseSalary,
        egp,
        false,
      ),
      SalaryField.absentDays => (
        context.tr('salary.days_absent'),
        _sheet.absentDays,
        null,
        false,
      ),
      SalaryField.lateDeduction => (
        context.tr('salary.line_late'),
        _sheet.lateDeduction,
        egp,
        false,
      ),
      SalaryField.deliveryOrders => (
        context.tr('salary.orders_count'),
        _sheet.deliveryOrders.toDouble(),
        null,
        true,
      ),
      SalaryField.bonus => (
        context.tr('notes.total_bonuses'),
        _sheet.totalBonus,
        egp,
        false,
      ),
      SalaryField.deduction => (
        context.tr('notes.total_deductions'),
        _sheet.totalDeduction,
        egp,
        false,
      ),
    };

    final result = await showEditTextDialog(
      context,
      title: context.tr('employee_details.edit_title', args: {'field': label}),
      initialValue: _plain(current),
      validator: _validate,
      keyboardType: TextInputType.numberWithOptions(decimal: !integer),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(integer ? r'^\d*' : r'^\d*\.?\d{0,2}'),
        ),
      ],
      suffixText: suffix,
    );
    if (result == null || !mounted) return;
    final value = double.tryParse(result);
    if (value == null) return;

    setState(() {
      _sheet = switch (field) {
        SalaryField.baseSalary => _sheet.copyWith(baseSalary: value),
        SalaryField.absentDays => _sheet.copyWith(absentDays: value),
        SalaryField.lateDeduction => _sheet.copyWith(lateDeduction: value),
        SalaryField.deliveryOrders => _sheet.copyWith(
          deliveryOrders: value.round(),
        ),
        SalaryField.bonus => _sheet.copyWith(bonusOverride: value),
        SalaryField.deduction => _sheet.copyWith(deductionOverride: value),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final sheet = _sheet;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.015,
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 8),
                    children: [
                      _HeroCard(sheet: sheet),
                      const SizedBox(height: 20),
                      SectionTitleWidget(context.tr('salary.summary')),
                      const SizedBox(height: 12),
                      _SummaryGrid(sheet: sheet),
                      const SizedBox(height: 20),
                      SectionTitleWidget(context.tr('salary.breakdown')),
                      const SizedBox(height: 12),
                      _BreakdownCard(sheet: sheet, onEdit: _edit),
                      const SizedBox(height: 20),
                      SectionTitleWidget(
                        context.tr('salary.adjustments_title'),
                      ),
                      const SizedBox(height: 12),
                      if (sheet.adjustments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              context.tr('notes.no_adjustments'),
                              style: Styles.textStyle14,
                            ),
                          ),
                        )
                      else
                        for (final item in sheet.adjustments)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AdjustmentCard(item: item, reasonLines: 6),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ButtonWidget(
                  width: double.infinity,
                  height: 52,
                  onPressed: () => exportPdfFlow(
                    context,
                    fileName:
                        'salary_${sheet.employee.id}_${sheet.record.id}.pdf',
                    employeePhone: sheet.employee.phoneNumber,
                    subtitle: context.tr('export.salary_subtitle'),
                    build: (l10n, ml) => SalaryPdfBuilder.build(
                      l10n: l10n,
                      sheet: _sheet,
                      mediumDate: ml.formatMediumDate,
                      shortDate: ml.formatShortMonthDay,
                    ),
                  ),
                  backgroundColor: kPrimaryBlue,
                  foregroundColor: Colors.white,
                  text: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('records.export_pdf'),
                        style: Styles.textStyle16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.sheet});

  final SalarySheet sheet;

  @override
  Widget build(BuildContext context) {
    final employee = sheet.employee;
    final period =
        '${formatMediumDate(context, sheet.record.from)}  -  '
        '${formatMediumDate(context, sheet.record.to)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryBlue, kDarkBlue],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBlue.withAlpha(60),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(46),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  employee.initials,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(46),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        jobLabel(context, employee.job),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.date_range_rounded,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  period,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.white.withAlpha(60)),
          const SizedBox(height: 14),
          Text(
            context.tr('salary.net_salary'),
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            formatAmount(context, sheet.net),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.sheet});

  final SalarySheet sheet;

  List<Widget> _tiles(BuildContext context) {
    return [
      _StatTile(
        icon: Icons.payments_outlined,
        label: context.tr('salary.base_salary'),
        value: formatAmount(context, sheet.baseSalary),
        color: kPrimaryBlue,
        subtitle:
            '${context.tr('salary.daily_rate')}: '
            '${formatAmount(context, sheet.dailyRate)}',
      ),
      _StatTile(
        icon: Icons.event_available_rounded,
        label: context.tr('salary.days_attended'),
        value: formatDays(sheet.attendedDays),
        color: kBonusColor,
        subtitle: sheet.offDays > 0
            ? context.tr(
                'salary.paid_off_days',
                args: {'off': '${sheet.offDays}'},
              )
            : null,
      ),
      _StatTile(
        icon: Icons.event_busy_rounded,
        label: context.tr('salary.days_absent'),
        value: formatDays(sheet.absentDays),
        color: kDeductionColor,
      ),
      _StatTile(
        icon: Icons.schedule_rounded,
        label: context.tr('salary.late_total'),
        value: formatAmount(context, sheet.lateDeduction),
        color: warning,
        subtitle: sheet.lateMinutes > 0
            ? formatDuration(context, sheet.lateMinutes)
            : null,
      ),
      if (sheet.isDelivery) ...[
        _StatTile(
          icon: Icons.motorcycle_rounded,
          label: context.tr('salary.orders_count'),
          value: '${sheet.deliveryOrders}',
          color: kPrimaryBlue,
        ),
        _StatTile(
          icon: Icons.local_shipping_outlined,
          label: context.tr('salary.line_delivery'),
          value: formatAmount(context, sheet.deliveryFees),
          color: kBonusColor,
          subtitle: context.tr(
            'salary.line_delivery_detail',
            args: {
              'count': '${sheet.deliveryOrders}',
              'fee': formatAmount(context, kDeliveryFeePerOrder),
            },
          ),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _tiles(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final width = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;
    final sub = subtitle;

    return Container(
      padding: const EdgeInsets.all(14),
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
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Text(sub, style: TextStyle(fontSize: 11.5, color: muted)),
          ],
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.sheet, required this.onEdit});

  final SalarySheet sheet;
  final void Function(SalaryField field) onEdit;

  Color _toneColor(BuildContext context, SalaryRowTone tone) => switch (tone) {
    SalaryRowTone.base => context.colors.onSurface,
    SalaryRowTone.add => kBonusColor,
    SalaryRowTone.subtract => kDeductionColor,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final rows = buildBreakdown(l10n, sheet, includeEmpty: true);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: cardDecoration(context),
      child: Column(
        children: [
          for (final row in rows) ...[
            _BreakdownRowTile(
              title: row.title,
              detail: row.detail,
              amount: signedAmount(l10n, row),
              color: _toneColor(context, row.tone),
              onEdit: () => onEdit(row.field),
            ),
            Divider(height: 1, color: colors.outlineVariant),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr('salary.net_salary'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  formatAmount(context, sheet.net),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRowTile extends StatelessWidget {
  const _BreakdownRowTile({
    required this.title,
    required this.detail,
    required this.amount,
    required this.color,
    required this.onEdit,
  });

  final String title;
  final String? detail;
  final String amount;
  final Color color;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceVariant;
    final d = detail;

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 6, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (d != null) ...[
                  const SizedBox(height: 3),
                  Text(d, style: TextStyle(fontSize: 12, color: muted)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          IconButton(
            onPressed: onEdit,
            tooltip: context.tr('employee_details.edit'),
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: kPrimaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
