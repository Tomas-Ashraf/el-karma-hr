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

Future<AdjustmentDraft?> showAdjustmentDialog(
  BuildContext context, {
  required List<EmployeeModel> employees,
  EmployeeModel? initialEmployee,
  EmployeeAdjustment? initial,
}) {
  assert(initial == null || initialEmployee != null);
  return showDialog<AdjustmentDraft>(
    context: context,
    builder: (_) => _AdjustmentDialog(
      employees: employees,
      initialEmployee: initialEmployee,
      initial: initial,
    ),
  );
}

class _AdjustmentDialog extends StatefulWidget {
  const _AdjustmentDialog({
    required this.employees,
    this.initialEmployee,
    this.initial,
  });

  final List<EmployeeModel> employees;
  final EmployeeModel? initialEmployee;
  final EmployeeAdjustment? initial;

  @override
  State<_AdjustmentDialog> createState() => _AdjustmentDialogState();
}

class _AdjustmentDialogState extends State<_AdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();

  bool get _isEdit => widget.initial != null;

  late final _amount = TextEditingController(
    text: widget.initial == null ? '' : _amountText(widget.initial!.amount),
  );
  late final _reason = TextEditingController(text: widget.initial?.reason);
  late String? _employeeId = widget.initialEmployee?.id;
  late DateTime? _date = _dayOf(widget.initial?.date ?? DateTime.now());
  late AdjustmentType _type = widget.initial?.type ?? AdjustmentType.bonus;

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _amountText(double value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toString();

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

    final employee = _isEdit
        ? widget.initialEmployee!
        : widget.employees.firstWhere((e) => e.id == _employeeId);
    final day = _date!;
    final time = widget.initial?.date ?? DateTime.now();

    Navigator.of(context).pop((
      employee: employee,
      type: _type,
      amount: double.parse(_amount.text.trim()),
      reason: _reason.text.trim(),
      date: DateTime(
        day.year,
        day.month,
        day.day,
        time.hour,
        time.minute,
        time.second,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        context.tr(_isEdit ? 'notes.edit_adjustment' : 'notes.add_adjustment'),
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
                if (_isEdit)
                  _ReadOnlyField(
                    label: context.tr('attendance.employee'),
                    value: widget.initialEmployee!.name,
                  )
                else
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
          child: Text(
            context.tr(_isEdit ? 'common.save' : 'add_employee.submit'),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Styles.textStyle13),
        const SizedBox(height: 6),
        InputDecorator(
          decoration: appInputDecoration(context),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: context.colors.onSurfaceVariant,
            ),
          ),
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
