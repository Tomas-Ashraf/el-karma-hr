import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:el_karma_ph/features/attendance_view.dart/manager/cubit/attendance_report_state.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:flutter/material.dart';

Future<AttendanceFilter?> showAttendanceFilterDialog(
  BuildContext context, {
  required List<EmployeeModel> employees,
  AttendanceFilter? initial,
}) {
  return showDialog<AttendanceFilter>(
    context: context,
    builder: (_) =>
        _AttendanceFilterDialog(employees: employees, initial: initial),
  );
}

class _AttendanceFilterDialog extends StatefulWidget {
  const _AttendanceFilterDialog({required this.employees, this.initial});

  final List<EmployeeModel> employees;
  final AttendanceFilter? initial;

  @override
  State<_AttendanceFilterDialog> createState() =>
      _AttendanceFilterDialogState();
}

class _AttendanceFilterDialogState extends State<_AttendanceFilterDialog> {
  final _formKey = GlobalKey<FormState>();

  late DateTime? _from =
      widget.initial?.from ??
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  late DateTime? _to =
      widget.initial?.to ??
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late String? _employeeId = widget.initial?.employee.id;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final employee = widget.employees.firstWhere((e) => e.id == _employeeId);
    Navigator.of(context)
        .pop(AttendanceFilter(employee: employee, from: _from!, to: _to!));
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
                DatePickerFormField(
                  label: context.tr('attendance.from'),
                  placeholder: context.tr('attendance.select_date'),
                  initialValue: _from,
                  onChanged: (date) => _from = date,
                  validator: (date) =>
                      date == null ? context.tr('common.required') : null,
                ),
                const SizedBox(height: 16),
                DatePickerFormField(
                  label: context.tr('attendance.to'),
                  placeholder: context.tr('attendance.select_date'),
                  initialValue: _to,
                  onChanged: (date) => _to = date,
                  validator: (date) {
                    if (date == null) return context.tr('common.required');
                    if (_from != null && date.isBefore(_from!)) {
                      return context.tr('attendance.invalid_range');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                LabeledDropdown<String>(
                  label: context.tr('attendance.employee'),
                  hint: context.tr('add_employee.select'),
                  initialValue: _employeeId,
                  items: {for (final e in widget.employees) e.id: e.name},
                  validator: (v) =>
                      v == null ? context.tr('common.required') : null,
                  onChanged: (v) => _employeeId = v,
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

class DatePickerFormField extends FormField<DateTime> {
  DatePickerFormField({
    super.key,
    required String label,
    required String placeholder,
    required ValueChanged<DateTime> onChanged,
    super.initialValue,
    super.validator,
  }) : super(
         autovalidateMode: AutovalidateMode.onUserInteraction,
         builder: (state) {
           final context = state.context;
           final value = state.value;

           Future<void> pick() async {
             final now = DateTime.now();
             final picked = await showDatePicker(
               context: context,
               initialDate: value ?? now,
               firstDate: DateTime(2020),
               lastDate: DateTime(now.year, now.month, now.day),
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
                       Icons.calendar_today_outlined,
                       size: 20,
                     ),
                   ),
                   child: Text(
                     value == null
                         ? placeholder
                         : formatMediumDate(context, value),
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
