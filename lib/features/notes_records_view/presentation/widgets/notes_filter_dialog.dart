import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:el_karma_ph/features/attendance_view.dart/presentation/widgets/attendance_filter_dialog.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:flutter/material.dart';

Future<NotesFilter?> showNotesFilterDialog(
  BuildContext context, {
  NotesFilter? initial,
}) {
  return showDialog<NotesFilter>(
    context: context,
    builder: (_) => _NotesFilterDialog(initial: initial),
  );
}

class _NotesFilterDialog extends StatefulWidget {
  const _NotesFilterDialog({this.initial});

  final NotesFilter? initial;

  @override
  State<_NotesFilterDialog> createState() => _NotesFilterDialogState();
}

class _NotesFilterDialogState extends State<_NotesFilterDialog> {
  final _formKey = GlobalKey<FormState>();

  late DateTime? _from =
      widget.initial?.from ??
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  late DateTime? _to =
      widget.initial?.to ??
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late String? _employee = widget.initial?.employee;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context)
        .pop(NotesFilter(employee: _employee!, from: _from!, to: _to!));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        context.tr('attendance.dialog_title'),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabeledDropdown<String>(
                  label: context.tr('attendance.employee'),
                  hint: context.tr('add_employee.select'),
                  initialValue: _employee,
                  items: {for (final e in kDummyEmployees) e: e},
                  validator: (v) =>
                      v == null ? context.tr('common.required') : null,
                  onChanged: (v) => _employee = v,
                ),
                const SizedBox(height: 16),
                DatePickerFormField(
                  label: context.tr('attendance.from'),
                  placeholder: context.tr('attendance.select_date'),
                  initialValue: _from,
                  onChanged: (d) => _from = d,
                  validator: (d) =>
                      d == null ? context.tr('common.required') : null,
                ),
                const SizedBox(height: 16),
                DatePickerFormField(
                  label: context.tr('attendance.to'),
                  placeholder: context.tr('attendance.select_date'),
                  initialValue: _to,
                  onChanged: (d) => _to = d,
                  validator: (d) {
                    if (d == null) return context.tr('common.required');
                    if (_from != null && d.isBefore(_from!)) {
                      return context.tr('attendance.invalid_range');
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('common.cancel')),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(context.tr('add_employee.submit')),
        ),
      ],
    );
  }
}
