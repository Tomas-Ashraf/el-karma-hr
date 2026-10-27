import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/features/add_employee_view/models/add_employee_model.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:el_karma_ph/core/utils/styles.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Text(message, style: Styles.textStyle14),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(ctx.tr('common.cancel')),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: destructive
                ? const Color(0xFFEF4444)
                : kPrimaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

ShiftRange buildShiftRange(TimeOfDay start, TimeOfDay end) {
  final now = DateTime.now();
  final startDate = DateTime(
    now.year,
    now.month,
    now.day,
    start.hour,
    start.minute,
  );
  var endDate = DateTime(now.year, now.month, now.day, end.hour, end.minute);
  if (!endDate.isAfter(startDate)) {
    endDate = endDate.add(const Duration(days: 1));
  }
  return ShiftRange(start: startDate, end: endDate);
}

Future<String?> showEditTextDialog(
  BuildContext context, {
  required String title,
  required String initialValue,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  TextCapitalization textCapitalization = TextCapitalization.none,
  String? suffixText,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _EditTextDialog(
      title: title,
      initialValue: initialValue,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      suffixText: suffixText,
    ),
  );
}

Future<String?> showEditDropdownDialog(
  BuildContext context, {
  required String title,
  required Map<String, String> items,
  String? initialValue,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _EditDropdownDialog(
      title: title,
      items: items,
      initialValue: items.containsKey(initialValue) ? initialValue : null,
    ),
  );
}

Future<ShiftRange?> showEditShiftDialog(
  BuildContext context, {
  required String title,
  required int number,
  ShiftRange? initial,
}) {
  return showDialog<ShiftRange>(
    context: context,
    builder: (_) =>
        _EditShiftDialog(title: title, number: number, initial: initial),
  );
}

class _EditDialogFrame extends StatelessWidget {
  const _EditDialogFrame({
    required this.title,
    required this.child,
    required this.onSave,
  });

  final String title;
  final Widget child;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(child: child),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('common.cancel')),
        ),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(context.tr('common.save')),
        ),
      ],
    );
  }
}

class _EditTextDialog extends StatefulWidget {
  const _EditTextDialog({
    required this.title,
    required this.initialValue,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.suffixText,
  });

  final String title;
  final String initialValue;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? suffixText;

  @override
  State<_EditTextDialog> createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<_EditTextDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return _EditDialogFrame(
      title: widget.title,
      onSave: _save,
      child: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _save(),
          decoration: appInputDecoration(
            context,
            suffixText: widget.suffixText,
          ),
        ),
      ),
    );
  }
}

class _EditDropdownDialog extends StatefulWidget {
  const _EditDropdownDialog({
    required this.title,
    required this.items,
    this.initialValue,
  });

  final String title;
  final Map<String, String> items;
  final String? initialValue;

  @override
  State<_EditDropdownDialog> createState() => _EditDropdownDialogState();
}

class _EditDropdownDialogState extends State<_EditDropdownDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? _value = widget.initialValue;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_value);
  }

  @override
  Widget build(BuildContext context) {
    return _EditDialogFrame(
      title: widget.title,
      onSave: _save,
      child: Form(
        key: _formKey,
        child: DropdownButtonFormField<String>(
          initialValue: _value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          dropdownColor: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          hint: Text(
            context.tr('add_employee.select'),
            style: const TextStyle(color: Colors.grey),
          ),
          decoration: appInputDecoration(context),
          validator: (v) => v == null ? context.tr('common.required') : null,
          onChanged: (v) => _value = v,
          items: [
            for (final entry in widget.items.entries)
              DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditShiftDialog extends StatefulWidget {
  const _EditShiftDialog({
    required this.title,
    required this.number,
    this.initial,
  });

  final String title;
  final int number;
  final ShiftRange? initial;

  @override
  State<_EditShiftDialog> createState() => _EditShiftDialogState();
}

class _EditShiftDialogState extends State<_EditShiftDialog> {
  final _formKey = GlobalKey<FormState>();
  late TimeOfDay? _start = widget.initial == null
      ? null
      : TimeOfDay.fromDateTime(widget.initial!.start);
  late TimeOfDay? _end = widget.initial == null
      ? null
      : TimeOfDay.fromDateTime(widget.initial!.end);

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(buildShiftRange(_start!, _end!));
  }

  @override
  Widget build(BuildContext context) {
    final args = {'n': '${widget.number}'};

    return _EditDialogFrame(
      title: widget.title,
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TimePickerFormField(
              label: context.tr('add_employee.shift_start', args: args),
              placeholder: context.tr('add_employee.select_time'),
              initialValue: _start,
              onChanged: (time) => _start = time,
              validator: (time) =>
                  time == null ? context.tr('common.required') : null,
            ),
            const SizedBox(height: 16),
            TimePickerFormField(
              label: context.tr('add_employee.shift_end', args: args),
              placeholder: context.tr('add_employee.select_time'),
              initialValue: _end,
              onChanged: (time) => _end = time,
              validator: (time) {
                if (time == null) return context.tr('common.required');
                if (_start != null && _start == time) {
                  return context.tr('add_employee.shift_same_time');
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
