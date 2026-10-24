import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

InputDecoration appInputDecoration(
  BuildContext context, {
  String? hintText,
  String? suffixText,
  Widget? suffixIcon,
  String? errorText,
}) {
  final borderColor = context.isDark
      ? const Color(0xFF334155)
      : const Color(0xFFBFDBFE);
  const errorColor = Color(0xFFEF4444);

  OutlineInputBorder border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Colors.grey),
    suffixText: suffixText,
    suffixIcon: suffixIcon,
    errorText: errorText,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: border(borderColor),
    enabledBorder: border(borderColor),
    focusedBorder: border(kPrimaryBlue, 1.5),
    errorBorder: border(errorColor),
    focusedErrorBorder: border(errorColor, 1.5),
  );
}

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.suffixText,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final String? suffixText;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Styles.textStyle13),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          onFieldSubmitted: onFieldSubmitted,
          decoration: appInputDecoration(context, suffixText: suffixText),
        ),
      ],
    );
  }
}

class LabeledDropdown<T> extends StatelessWidget {
  const LabeledDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.hint,
    this.validator,
  });

  final String label;
  final Map<T, String> items;
  final T? initialValue;
  final String? hint;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Styles.textStyle13),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: initialValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          dropdownColor: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          hint: hint == null
              ? null
              : Text(hint!, style: const TextStyle(color: Colors.grey)),
          decoration: appInputDecoration(context),
          validator: validator,
          onChanged: onChanged,
          items: [
            for (final entry in items.entries)
              DropdownMenuItem<T>(value: entry.key, child: Text(entry.value)),
          ],
        ),
      ],
    );
  }
}

class TimePickerFormField extends FormField<TimeOfDay> {
  TimePickerFormField({
    super.key,
    required String label,
    required String placeholder,
    required ValueChanged<TimeOfDay> onChanged,
    super.initialValue,
    super.validator,
  }) : super(
         builder: (state) {
           final context = state.context;
           final value = state.value;

           Future<void> pick() async {
             final picked = await showTimePicker(
               context: context,
               initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
             );
             if (picked == null) return;
             state.didChange(picked);
             onChanged(picked);
           }

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(label, style: Styles.textStyle13),
               const SizedBox(height: 6),
               InkWell(
                 borderRadius: BorderRadius.circular(12),
                 onTap: pick,
                 child: InputDecorator(
                   isEmpty: value == null,
                   decoration: appInputDecoration(
                     context,
                     errorText: state.errorText,
                     suffixIcon: const Icon(
                       Icons.access_time_rounded,
                       size: 20,
                     ),
                   ),
                   child: Text(
                     value == null ? placeholder : value.format(context),
                     style: TextStyle(
                       fontSize: 16,
                       color: value == null ? Colors.grey : null,
                     ),
                   ),
                 ),
               ),
             ],
           );
         },
       );
}
