import 'dart:developer' show log;

import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

bool get canPickContact =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

class ContactPickerButton extends StatefulWidget {
  const ContactPickerButton({super.key, required this.onPicked});

  final ValueChanged<String> onPicked;

  @override
  State<ContactPickerButton> createState() => _ContactPickerButtonState();
}

class _ContactPickerButtonState extends State<ContactPickerButton> {
  final _picker = FlutterNativeContactPicker();

  Future<void> _pick() async {
    final messenger = ScaffoldMessenger.of(context);
    final failedText = context.tr('add_employee.contacts_failed');

    try {
      final contact = await _picker.selectPhoneNumber();
      final raw = contact?.selectedPhoneNumber;
      if (raw == null || !mounted) return;

      final cleaned = raw.replaceAll(RegExp(r'[^0-9+]'), '');
      if (cleaned.isEmpty) return;
      widget.onPicked(cleaned.length > 15 ? cleaned.substring(0, 15) : cleaned);
    } catch (e) {
      log('Failed to pick contact: $e');
      messenger.showSnackBar(
        SnackBar(content: Text(failedText), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.tr('add_employee.pick_contact'),
      icon: const Icon(Icons.contacts_outlined, color: kPrimaryBlue),
      onPressed: _pick,
    );
  }
}
