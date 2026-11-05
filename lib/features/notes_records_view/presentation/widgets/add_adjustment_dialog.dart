import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:el_karma_ph/features/attendance_view.dart/presentation/widgets/attendance_filter_dialog.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<AdjustmentDraft?> showAddAdjustmentDialog(
  BuildContext context, {
  required List<EmployeeModel> employees,
  EmployeeModel? initialEmployee,
}) {
  return showDialog<AdjustmentDraft>(
    context: context,
    builder: (_) => _AddAdjustmentDialog(
      employees: employees,
      initialEmployee: initialEmployee,
    ),
  );
}

class _AddAdjustmentDialog extends StatefulWidget {
  const _AddAdjustmentDialog({required this.employees, this.initialEmployee});

  final List<EmployeeModel> employees;
  final EmployeeModel? initialEmployee;

  @override
  State<_AddAdjustmentDialog> createState() => _AddAdjustmentDialogState();
}

class _AddAdjustmentDialogState extends State<_AddAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  late String? _employeeId = widget.initialEmployee?.id;
  late DateTime? _date = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  AdjustmentType _type = AdjustmentType.bonus;

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  String? _validateAmount(String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return context.tr('common.required');
    final n = double.tryParse(text);
    if (n == null || n <= 0) return context.tr('settings.invalid_amount');
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final employee = widget.employees.firstWhere((e) => e.id == _employeeId);
    final day = _date!;
    final now = DateTime.now();

    Navigator.of(context).pop((
      employee: employee,
      type: _type,
      amount: double.parse(_amount.text.trim()),
      reason: _reason.text.trim(),
      date: DateTime(
        day.year,
        day.month,
        day.day,
        now.hour,
        now.minute,
        now.second,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        context.tr('notes.add_adjustment'),
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
                  initialValue: _employeeId,
                  items: {for (final e in widget.employees) e.id: e.name},
                  validator: (v) =>
                      v == null ? context.tr('common.required') : null,
                  onChanged: (v) => _employeeId = v,
                ),
                const SizedBox(height: 16),
                Text(context.tr('notes.type'), style: Styles.textStyle13),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _TypeTile(
                        label: context.tr('notes.bonus'),
                        icon: Icons.arrow_upward_rounded,
                        color: kBonusColor,
                        selected: _type == AdjustmentType.bonus,
                        onTap: () =>
                            setState(() => _type = AdjustmentType.bonus),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TypeTile(
                        label: context.tr('notes.deduction'),
                        icon: Icons.arrow_downward_rounded,
                        color: kDeductionColor,
                        selected: _type == AdjustmentType.deduction,
                        onTap: () =>
                            setState(() => _type = AdjustmentType.deduction),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: context.tr('notes.amount'),
                  controller: _amount,
                  validator: _validateAmount,
                  suffixText: context.tr('common.egp'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                DatePickerFormField(
                  label: context.tr('notes.date'),
                  placeholder: context.tr('attendance.select_date'),
                  initialValue: _date,
                  onChanged: (d) => _date = d,
                  validator: (d) =>
                      d == null ? context.tr('common.required') : null,
                ),
                const SizedBox(height: 16),
                Text(context.tr('notes.reason'), style: Styles.textStyle13),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _reason,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? context.tr('common.required')
                      : null,
                  decoration: appInputDecoration(context),
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

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(31) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : context.colors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? color : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? color : context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
