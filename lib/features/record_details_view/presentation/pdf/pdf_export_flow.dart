import 'dart:async';
import 'dart:developer' show log;
import 'dart:typed_data';

import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/whatsapp_sender.dart';
import 'package:el_karma_ph/features/record_details_view/presentation/view/pdf_preview_view.dart';
import 'package:el_karma_ph/features/record_details_view/presentation/widgets/export_pdf_dialog.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

Future<void> exportPdfFlow(
  BuildContext context, {
  required Future<Uint8List> Function(
    AppLocalizations l10n,
    MaterialLocalizations ml,
  )
  build,
  required String fileName,
  required String employeePhone,
  String? subtitle,
}) async {
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
    final bytes = await build(l10n, ml);
    navigator.pop();
    if (!context.mounted) return;

    showExportPdfDialog(
      context,
      subtitle: subtitle,
      onPreview: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PdfPreviewView(bytes: bytes, fileName: fileName),
        ),
      ),
      onShare: () => Printing.sharePdf(bytes: bytes, filename: fileName),
      onWhatsApp: () => _sendWhatsApp(context, bytes, fileName, employeePhone),
    );
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

Future<void> _sendWhatsApp(
  BuildContext context,
  Uint8List bytes,
  String fileName,
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
      fileName: fileName,
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
