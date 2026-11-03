import 'dart:typed_data';

import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewView extends StatelessWidget {
  const PdfPreviewView({
    super.key,
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          context.tr('export.preview'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PdfPreview(
        build: (_) => bytes,
        pdfFileName: fileName,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
      ),
    );
  }
}
