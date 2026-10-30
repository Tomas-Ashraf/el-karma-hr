import 'dart:async';
import 'dart:developer' show log;
import 'dart:typed_data';

import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/whatsapp_sender.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/attendance_view.dart/presentation/widgets/attendance_entry_card.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/employees_view/repos/employees_repo.dart';
import 'package:el_karma_ph/features/record_details_view/presentation/pdf/attendance_pdf_builder.dart';
import 'package:el_karma_ph/features/record_details_view/presentation/view/pdf_preview_view.dart';
import 'package:el_karma_ph/features/record_details_view/presentation/widgets/export_pdf_dialog.dart';
import 'package:el_karma_ph/features/record_details_view/presentation/widgets/header_card.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class RecordDetailsViewBody extends StatelessWidget {
  const RecordDetailsViewBody({super.key, required this.record});

  final RecordPreview record;

  String get _fileName => 'attendance_${record.employeeId}_${record.id}.pdf';

  Future<EmployeeModel?> _loadEmployee() async {
    try {
      return await EmployeesRepo().getEmployee(record.employeeId);
    } catch (e) {
      log('Could not load employee for PDF: $e');
      return null;
    }
  }

  Future<void> _exportPdf(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final ml = MaterialLocalizations.of(context);
    final failedText = context.tr('export.failed');

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _GeneratingDialog(),
      ),
    );

    try {
      final employee = await _loadEmployee();
      final bytes = await AttendancePdfBuilder.build(
        l10n: l10n,
        fmt: PdfFormatters(
          time: (d) => ml.formatTimeOfDay(TimeOfDay.fromDateTime(d)),
          shortDate: ml.formatShortMonthDay,
          mediumDate: ml.formatMediumDate,
        ),
        record: record,
        job: employee?.job ?? '',
      );
      navigator.pop();
      if (!context.mounted) return;
      _showResult(context, bytes, employee);
    } catch (e) {
      log('Failed to create PDF: $e');
      navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(failedText), backgroundColor: Colors.red),
        );
    }
  }

  void _showResult(
    BuildContext context,
    Uint8List bytes,
    EmployeeModel? employee,
  ) {
    showExportPdfDialog(
      context,
      onPreview: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PdfPreviewView(bytes: bytes, fileName: _fileName),
        ),
      ),
      onShare: () => Printing.sharePdf(bytes: bytes, filename: _fileName),
      onWhatsApp: () =>
          _sendWhatsApp(context, bytes, employee?.phoneNumber ?? ''),
    );
  }

  Future<void> _sendWhatsApp(
    BuildContext context,
    Uint8List bytes,
    String employeePhone,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final notInstalled = context.tr('whatsapp.not_installed');
    final failed = context.tr('whatsapp.failed');

    final phone = await showWhatsappTargetDialog(
      context,
      employeePhone: employeePhone,
    );
    if (phone == null) return;

    try {
      final opened = await WhatsAppSender.sendPdf(
        bytes: bytes,
        fileName: _fileName,
        phone: phone,
      );
      if (!opened) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(notInstalled), backgroundColor: Colors.red),
          );
      }
    } catch (e) {
      log('Failed to open WhatsApp: $e');
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(failed), backgroundColor: Colors.red),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 600.0;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.015,
            ),
            child: Column(
              children: [
                HeaderCard(record: record),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: record.entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        AttendanceEntryCard(entry: record.entries[index]),
                  ),
                ),
                const SizedBox(height: 12),
                ButtonWidget(
                  width: double.infinity,
                  height: 52,
                  onPressed: () => _exportPdf(context),
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

class _GeneratingDialog extends StatelessWidget {
  const _GeneratingDialog();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(context.tr('export.generating'))),
          ],
        ),
      ),
    );
  }
}
