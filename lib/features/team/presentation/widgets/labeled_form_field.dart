import 'package:el_karma_ph/core/app_colors.dart';
import 'package:el_karma_ph/core/utils/employee/employee_field.dart';
import 'package:flutter/material.dart';

/// Required input (text or dropdown) used by the add-member form.
class LabeledFormField extends StatelessWidget {
  const LabeledFormField({
    super.key,
    required this.field,
    required this.onSaved,
  });

  final EmployeeField field;
  final ValueChanged<String> onSaved;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color, width: 1.5),
  );

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: _border(AppColors.line),
    enabledBorder: _border(AppColors.line),
    focusedBorder: _border(AppColors.blue),
    errorBorder: _border(AppColors.red),
    focusedErrorBorder: _border(AppColors.red),
  );

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? '${field.label} is required' : null;

  @override
  Widget build(BuildContext context) {
    final options = field.options;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: field.label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (options != null)
            DropdownButtonFormField<String>(
              decoration: _decoration('Select ${field.label.toLowerCase()}'),
              items: [
                for (final o in options)
                  DropdownMenuItem(value: o, child: Text(o)),
              ],
              validator: _required,
              onChanged: (_) {},
              onSaved: (v) => onSaved(v!),
            )
          else
            TextFormField(
              decoration: _decoration(field.label),
              validator: _required,
              onSaved: (v) => onSaved(v!.trim()),
            ),
        ],
      ),
    );
  }
}
