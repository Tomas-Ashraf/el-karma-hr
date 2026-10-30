import 'dart:typed_data';

import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/assets.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/core/utils/weekdays.dart';
import 'package:el_karma_ph/features/attendance_view.dart/models/attendance_entry.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';
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
const _late = PdfColor.fromInt(0xFFB45309);
const _lateBg = PdfColor.fromInt(0xFFFEF3C7);
const _bad = PdfColor.fromInt(0xFFB91C1C);
const _badBg = PdfColor.fromInt(0xFFFEE2E2);
const _off = PdfColor.fromInt(0xFF1D4ED8);
const _offBg = PdfColor.fromInt(0xFFDBEAFE);

class PdfFormatters {
  const PdfFormatters({
    required this.time,
    required this.shortDate,
    required this.mediumDate,
  });

  final String Function(DateTime) time;
  final String Function(DateTime) shortDate;
  final String Function(DateTime) mediumDate;
}

class AttendancePdfBuilder {
  AttendancePdfBuilder._();

  static Future<Uint8List> build({
    required AppLocalizations l10n,
    required PdfFormatters fmt,
    required RecordPreview record,
    String job = '',
  }) async {
    final regular = await PdfGoogleFonts.cairoRegular();
    final bold = await PdfGoogleFonts.cairoBold();
    final logoData = await rootBundle.load(AssetsData.logo);
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    final report = _Report(
      l10n: l10n,
      fmt: fmt,
      record: record,
      job: job,
      logo: logo,
    );

    final doc = pw.Document(
      title: '${l10n.translate('pdf.title')} - ${record.employeeName}',
      author: l10n.translate('pdf.pharmacy'),
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 32),
        header: report.pageHeader,
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
    required this.fmt,
    required this.record,
    required this.job,
    required this.logo,
  }) : isRtl = l10n.locale.languageCode == 'ar';

  final AppLocalizations l10n;
  final PdfFormatters fmt;
  final RecordPreview record;
  final String job;
  final pw.MemoryImage logo;
  final bool isRtl;

  pw.TextDirection get _dir =>
      isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
  pw.TextAlign get _align => isRtl ? pw.TextAlign.right : pw.TextAlign.left;

  String _t(String key, {Map<String, String>? args}) =>
      l10n.translate(key, args: args);

  pw.Widget _wrap(pw.Widget child) =>
      pw.Directionality(textDirection: _dir, child: child);

  pw.Widget _text(
    String value, {
    double size = 10,
    bool bold = false,
    PdfColor color = _ink,
  }) {
    return pw.Text(
      value,
      textAlign: _align,
      style: pw.TextStyle(
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color,
      ),
    );
  }

  List<pw.Widget> body() {
    final entries = record.entries;
    return [
      _banner(),
      pw.SizedBox(height: 14),
      _infoCard(),
      pw.SizedBox(height: 14),
      _summary(),
      pw.SizedBox(height: 18),
      _tableHeader(),
      for (final (i, e) in entries.indexed) _row(e, i),
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
                _text(_t('pdf.title'), size: 12, color: _bannerSub),
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
          row(_t('pdf.employee'), record.employeeName),
          if (job.trim().isNotEmpty) row(_t('pdf.job'), job.trim()),
          row(
            _t('pdf.period'),
            '${fmt.mediumDate(record.from)}  -  ${fmt.mediumDate(record.to)}',
          ),
        ],
      ),
    );
  }

  pw.Widget _summary() {
    final attendedDays = record.entries
        .where((e) => e.kind == AttendanceEntryKind.attended)
        .map((e) => DateTime(e.day.year, e.day.month, e.day.day))
        .toSet()
        .length;
    final daysOff = record.entries
        .where((e) => e.kind == AttendanceEntryKind.dayOff)
        .length;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _statCard(_t('pdf.days_attended'), '$attendedDays', _good, _goodBg),
        pw.SizedBox(width: 8),
        _statCard(_t('pdf.days_absent'), '${record.absentCount}', _bad, _badBg),
        pw.SizedBox(width: 8),
        _statCard(_t('pdf.days_off'), '$daysOff', _off, _offBg),
        pw.SizedBox(width: 8),
        _statCard(
          _t('pdf.total_late'),
          formatMinutes(l10n, record.lateMinutesTotal),
          _late,
          _lateBg,
        ),
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
            _text(value, size: 14, bold: true, color: fg),
          ],
        ),
      ),
    );
  }

  pw.Widget _tableHeader() {
    pw.Widget cell(String label, int flex) => pw.Expanded(
      flex: flex,
      child: _text(label, size: 9.5, bold: true, color: PdfColors.white),
    );

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
          cell(_t('pdf.col_date'), 3),
          cell(_t('dashboard.check_in'), 3),
          cell(_t('dashboard.check_out'), 3),
          cell('', 4),
        ],
      ),
    );
  }

  pw.Widget _row(AttendanceEntry e, int index) {
    final r = e.record;
    final shade = index.isEven ? PdfColors.white : _surface;

    pw.Widget cell(int flex, List<pw.Widget> children) => pw.Expanded(
      flex: flex,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: children,
      ),
    );

    final dayCell = cell(3, [
      _text(_t('day.${weekdayKey(e.day)}'), size: 10.5, bold: true),
      _text(fmt.shortDate(e.day), size: 8.5, color: _muted),
      if (e.shiftNumber != null)
        _text(
          _t('add_employee.shift_title', args: {'n': '${e.shiftNumber}'}),
          size: 8.5,
          color: _blue,
        ),
    ]);

    List<pw.Widget> timeCell(DateTime? time) => [
      _text(time == null ? '—' : fmt.time(time), size: 10.5, bold: true),
      if (time != null && !_sameDay(time, e.day))
        _text(fmt.shortDate(time), size: 8.5, color: _muted),
    ];

    final List<(String, PdfColor)> notes;
    if (r == null) {
      notes = e.kind == AttendanceEntryKind.absent
          ? [(_t('attendance.absent'), _bad)]
          : [(_t('add_employee.day_off'), _off)];
    } else {
      notes = [
        if (r.checkIn == null)
          (_t('dashboard.no_check_in'), _late)
        else if (r.isLate)
          (_t('dashboard.late_by', args: {'min': '${r.minutesLate}'}), _late)
        else
          (_t('dashboard.on_time'), _good),
        if (r.leftEarly)
          (
            _t('dashboard.left_early_by', args: {'min': '${r.minutesEarly}'}),
            _bad,
          ),
      ];
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        color: shade,
        border: const pw.Border(
          bottom: pw.BorderSide(color: _line, width: 0.5),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          dayCell,
          cell(3, timeCell(r?.checkIn)),
          cell(3, timeCell(r?.checkOut)),
          cell(4, [
            for (final n in notes)
              _text(n.$1, size: 9.5, bold: true, color: n.$2),
          ]),
        ],
      ),
    );
  }

  pw.Widget pageHeader(pw.Context ctx) {
    if (ctx.pageNumber == 1) return pw.SizedBox();
    return _wrap(
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _text(
            '${_t('pdf.pharmacy')}  •  ${record.employeeName}',
            size: 10,
            bold: true,
            color: _darkBlue,
          ),
          pw.SizedBox(height: 8),
          _tableHeader(),
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
                _t(
                  'pdf.generated',
                  args: {'date': fmt.mediumDate(DateTime.now())},
                ),
                size: 8,
                color: _muted,
              ),
              _text(
                _t(
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

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
