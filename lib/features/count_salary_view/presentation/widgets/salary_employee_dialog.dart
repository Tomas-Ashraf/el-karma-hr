import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_dummy_data.dart';
import 'package:flutter/material.dart';

Future<SalaryEmployee?> showSalaryEmployeeDialog(
  BuildContext context, {
  SalaryEmployee? initial,
}) {
  return showDialog<SalaryEmployee>(
    context: context,
    builder: (_) => _SalaryEmployeeDialog(initial: initial),
  );
}

class _SalaryEmployeeDialog extends StatefulWidget {
  const _SalaryEmployeeDialog({this.initial});

  final SalaryEmployee? initial;

  @override
  State<_SalaryEmployeeDialog> createState() => _SalaryEmployeeDialogState();
}

class _SalaryEmployeeDialogState extends State<_SalaryEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? _employeeId = widget.initial?.id;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final employee = kDummyEmployees.firstWhere((e) => e.id == _employeeId);
    Navigator.of(context).pop(employee);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        context.tr('salary.select_employee'),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: LabeledDropdown<String>(
              label: context.tr('attendance.employee'),
              hint: context.tr('add_employee.select'),
              initialValue: _employeeId,
              items: {for (final e in kDummyEmployees) e.id: e.name},
              validator: (v) =>
                  v == null ? context.tr('common.required') : null,
              onChanged: (v) => _employeeId = v,
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
          child: Text(context.tr('common.confirm')),
        ),
      ],
    );
  }
}
