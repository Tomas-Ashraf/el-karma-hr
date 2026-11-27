import 'dart:typed_data';

import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/assets.dart';
import 'package:el_karma_ph/core/utils/employee_jobs.dart';
import 'package:el_karma_ph/core/utils/money_format.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_breakdown.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const _blue = PdfColor.fromInt(0xFF3B82F6);
const _darkBlue = PdfColor.fromInt(0xFF2E5FA3);
const _ink = PdfColor.fromInt(0xFF0F172A);
const _muted = PdfColor.fromInt(0xFF64748B);
const _surface = PdfColor.fromInt(0xFFF8FAFC);
const _line = PdfColor.fromInt(0xFFE2E8F0);
const _bannerSub = PdfColor.fromInt(0xFFDBEAFE);

const _good = PdfColor.fromInt(0xFF15803D);
const _goodBg = PdfColor.fromInt(0xFFDCFCE7);
const _bad = PdfColor.fromInt(0xFFB91C1C);
const _badBg = PdfColor.fromInt(0xFFFEE2E2);
const _late = PdfColor.fromInt(0xFFB45309);
const _lateBg = PdfColor.fromInt(0xFFFEF3C7);
const _netBg = PdfColor.fromInt(0xFFDBEAFE);

class SalaryPdfBuilder {
  SalaryPdfBuilder._();

  static Future<Uint8List> build({
    required AppLocalizations l10n,
    required SalarySheet sheet,
    required String Function(DateTime) mediumDate,
    required String Function(DateTime) shortDate,
  }) async {
    final regular = await PdfGoogleFonts.cairoRegular();
    final bold = await PdfGoogleFonts.cairoBold();
    final logoData = await rootBundle.load(AssetsData.logo);
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    final report = _Report(
      l10n: l10n,
      sheet: sheet,
      mediumDate: mediumDate,
      shortDate: shortDate,
      logo: logo,
    );

    final doc = pw.Document(
      title: '${l10n.translate('salary.sheet_title')} - ${sheet.employee.name}',
      author: l10n.translate('pdf.pharmacy'),
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 32),
        footer: report.footer,
        build: (_) => report.body(),
      ),
    );

    return doc.save();
  }
}

class _Report {
  _Report({
    required this.l10n,
    required this.sheet,
    required this.mediumDate,
    required this.shortDate,
    required this.logo,
  }) : isRtl = l10n.locale.languageCode == 'ar';

  final AppLocalizations l10n;
  final SalarySheet sheet;
  final String Function(DateTime) mediumDate;
  final String Function(DateTime) shortDate;
  final pw.MemoryImage logo;
  final bool isRtl;

  pw.TextDirection get _dir =>
      isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
  pw.TextAlign get _align => isRtl ? pw.TextAlign.right : pw.TextAlign.left;
  pw.TextAlign get _endAlign => isRtl ? pw.TextAlign.left : pw.TextAlign.right;

  String _t(String key) => l10n.translate(key);

  pw.Widget _wrap(pw.Widget child) =>
      pw.Directionality(textDirection: _dir, child: child);

  pw.Widget _text(
    String value, {
    double size = 10,
    bool bold = false,
    PdfColor color = _ink,
    pw.TextAlign? align,
  }) {
    return pw.Text(
      value,
      textAlign: align ?? _align,
      style: pw.TextStyle(
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color,
      ),
    );
  }

  PdfColor _toneColor(SalaryRowTone tone) => switch (tone) {
    SalaryRowTone.base => _ink,
    SalaryRowTone.add => _good,
    SalaryRowTone.subtract => _bad,
  };

  List<pw.Widget> body() {
    final rows = buildBreakdown(l10n, sheet);
    return [
      _banner(),
      pw.SizedBox(height: 14),
      _infoCard(),
      pw.SizedBox(height: 14),
      _stats(),
      pw.SizedBox(height: 18),
      _section(_t('salary.breakdown')),
      pw.SizedBox(height: 6),
      _tableHeader(_t('salary.col_item'), _t('salary.col_amount')),
      for (final (i, row) in rows.indexed) _breakdownRow(row, i),
      if (sheet.adjustments.isNotEmpty) ...[
        pw.SizedBox(height: 18),
        _section(_t('salary.adjustments_title')),
        pw.SizedBox(height: 6),
        _tableHeader(_t('notes.reason'), _t('salary.col_amount')),
        for (final (i, a) in sheet.adjustments.indexed) _adjustmentRow(a, i),
      ],
      pw.SizedBox(height: 16),
      _netBox(),
    ].map(_wrap).toList();
  }

  pw.Widget _banner() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: _darkBlue,
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 64,
            height: 64,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Image(logo, fit: pw.BoxFit.contain),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _text(
                  _t('pdf.pharmacy'),
                  size: 19,
                  bold: true,
                  color: PdfColors.white,
                ),
                pw.SizedBox(height: 4),
                _text(_t('salary.sheet_title'), size: 12, color: _bannerSub),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _infoCard() {
    pw.Widget row(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 80, child: _text(label, color: _muted)),
          pw.Expanded(child: _text(value, size: 11, bold: true)),
        ],
      ),
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _surface,
        border: pw.Border.all(color: _line),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          row(_t('pdf.employee'), sheet.employee.name),
          row(_t('pdf.job'), jobLabelOf(l10n, sheet.employee.job)),
          row(
            _t('pdf.period'),
            '${mediumDate(sheet.record.from)}  -  '
            '${mediumDate(sheet.record.to)}',
          ),
        ],
      ),
    );
  }

  pw.Widget _stats() {
    final primary = <pw.Widget>[
      _statCard(
        _t('salary.base_salary'),
        formatAmountOf(l10n, sheet.baseSalary),
        _darkBlue,
        _netBg,
      ),
      _statCard(
        _t('salary.days_attended'),
        formatDays(sheet.attendedDays),
        _good,
        _goodBg,
      ),
      _statCard(
        _t('salary.days_absent'),
        formatDays(sheet.absentDays),
        _bad,
        _badBg,
      ),
      _statCard(
        _t('salary.late_total'),
        formatAmountOf(l10n, sheet.lateDeduction),
        _late,
        _lateBg,
      ),
    ];

    final delivery = <pw.Widget>[
      _statCard(
        _t('salary.orders_count'),
        '${sheet.deliveryOrders}',
        _darkBlue,
        _netBg,
      ),
      _statCard(
        _t('salary.line_delivery'),
        formatAmountOf(l10n, sheet.deliveryFees),
        _good,
        _goodBg,
      ),
    ];

    pw.Widget cardsRow(List<pw.Widget> cards) => pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final (i, card) in cards.indexed) ...[
          if (i > 0) pw.SizedBox(width: 8),
          card,
        ],
      ],
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        cardsRow(primary),
        if (sheet.isDelivery) ...[pw.SizedBox(height: 8), cardsRow(delivery)],
      ],
    );
  }

  pw.Widget _statCard(String label, String value, PdfColor fg, PdfColor bg) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _text(label, size: 9, color: fg),
            pw.SizedBox(height: 6),
            _text(value, size: 13, bold: true, color: fg),
          ],
        ),
      ),
    );
  }

  pw.Widget _section(String title) =>
      _text(title, size: 12, bold: true, color: _darkBlue);

  pw.Widget _tableHeader(String left, String right) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const pw.BoxDecoration(
        color: _blue,
        borderRadius: pw.BorderRadius.only(
          topLeft: pw.Radius.circular(8),
          topRight: pw.Radius.circular(8),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 6,
            child: _text(left, size: 9.5, bold: true, color: PdfColors.white),
          ),
          pw.Expanded(
            flex: 3,
            child: _text(
              right,
              size: 9.5,
              bold: true,
              color: PdfColors.white,
              align: _endAlign,
            ),
          ),
        ],
      ),
    );
  }

  pw.BoxDecoration _rowDecoration(int index) => pw.BoxDecoration(
    color: index.isEven ? PdfColors.white : _surface,
    border: const pw.Border(bottom: pw.BorderSide(color: _line, width: 0.5)),
  );

  pw.Widget _breakdownRow(SalaryBreakdownRow row, int index) {
    final detail = row.detail;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: _rowDecoration(index),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 6,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _text(row.title, size: 10.5, bold: true),
                if (detail != null) _text(detail, size: 8.5, color: _muted),
              ],
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: _text(
              signedAmount(l10n, row),
              size: 10.5,
              bold: true,
              color: _toneColor(row.tone),
              align: _endAlign,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _adjustmentRow(EmployeeAdjustment a, int index) {
    final color = a.isBonus ? _good : _bad;
    final type = _t(a.isBonus ? 'notes.bonus' : 'notes.deduction');
    final reason = a.reason.trim();

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: _rowDecoration(index),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 6,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _text(reason.isEmpty ? type : reason, size: 10.5, bold: true),
                _text('$type · ${shortDate(a.date)}', size: 8.5, color: _muted),
              ],
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: _text(
              '${a.isBonus ? '+' : '-'}${formatAmountOf(l10n, a.amount)}',
              size: 10.5,
              bold: true,
              color: color,
              align: _endAlign,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _netBox() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: pw.BoxDecoration(
        color: _netBg,
        border: pw.Border.all(color: _blue, width: 1),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: _text(_t('salary.net_salary'), size: 13, bold: true),
          ),
          _text(
            formatAmountOf(l10n, sheet.net),
            size: 17,
            bold: true,
            color: _darkBlue,
          ),
        ],
      ),
    );
  }

  pw.Widget footer(pw.Context ctx) {
    return _wrap(
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Divider(color: _line, thickness: 0.5),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _text(
                l10n.translate(
                  'pdf.generated',
                  args: {'date': mediumDate(DateTime.now())},
                ),
                size: 8,
                color: _muted,
              ),
              _text(
                l10n.translate(
                  'pdf.page',
                  args: {
                    'n': '${ctx.pageNumber}',
                    'total': '${ctx.pagesCount}',
                  },
                ),
                size: 8,
                color: _muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
