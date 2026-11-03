import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

const kDefaultCountryCode = '20';

String? normalizeWhatsAppNumber(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('00')) {
    digits = digits.substring(2);
  } else if (digits.startsWith('0')) {
    digits = '$kDefaultCountryCode${digits.substring(1)}';
  } else if (digits.length == 10 && digits.startsWith('1')) {
    digits = '$kDefaultCountryCode$digits';
  }
  return digits.length >= 8 && digits.length <= 15 ? digits : null;
}

class WhatsAppSender {
  WhatsAppSender._();

  static const _channel = MethodChannel('el_karma_ph/whatsapp');

  static Future<bool> sendPdf({
    required Uint8List bytes,
    required String fileName,
    required String phone,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      return true;
    }
    final result = await _channel.invokeMethod<String>('sendPdf', {
      'bytes': bytes,
      'fileName': fileName,
      'phone': phone,
    });
    return result == 'ok';
  }
}
