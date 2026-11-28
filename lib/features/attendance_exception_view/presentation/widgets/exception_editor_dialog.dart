import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:el_karma_ph/features/attendance_exception_view/models/attendance_exception_models.dart';
import 'package:el_karma_ph/features/attendance_exception_view/presentation/widgets/exception_card.dart';
import 'package:el_karma_ph/features/attendance_exception_view/presentation/widgets/exception_day_field.dart';
import 'package:flutter/material.dart';

Future<AttendanceException?> showExceptionEditorDialog(
  BuildContext context, {
  required String employeeId,
  AttendanceException? initial,
}) {
  return showDialog<AttendanceException>(
    context: context,
    builder: (_) =>
        _ExceptionEditorDialog(employeeId: employeeId, initial: initial),
  );
}

class _ExceptionEditorDialog extends StatefulWidget {
  const _ExceptionEditorDialog({required this.employeeId, this.initial});

  final String employeeId;
  final AttendanceException? initial;

  @override
  State<_ExceptionEditorDialog> createState() => _ExceptionEditorDialogState();
}

class _ExceptionEditorDialogState extends State<_ExceptionEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  bool get _isEdit => widget.initial != null;

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  late ExceptionType _type = widget.initial?.type ?? ExceptionType.lateArrival;
  late DateTime? _date = widget.initial?.date ?? _today;
  late TimeOfDay? _time = widget.initial?.time;
  late final _reason = TextEditingController(text: widget.initial?.reason);

  bool get _isDayOff => _type == ExceptionType.dayOff;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      AttendanceException(
        id: widget.initial?.id ?? '',
        employeeId: widget.employeeId,
        type: _type,
        date: _date!,
        time: _isDayOff ? null : _time,
        reason: _reason.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeLabelKey = _type == ExceptionType.lateArrival
        ? 'exceptions.arrive_time'
        : 'exceptions.leave_time';

    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        context.tr(_isEdit ? 'exceptions.edit' : 'exceptions.add'),
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
                Text(context.tr('exceptions.type'), style: Styles.textStyle13),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in ExceptionType.values)
                      ChoiceChip(
                        avatar: Icon(
                          t.icon,
                          size: 16,
                          color: _type == t
                              ? t.color
                              : context.colors.onSurfaceVariant,
                        ),
                        label: Text(context.tr(t.labelKey)),
                        selected: _type == t,
                        onSelected: (_) => setState(() => _type = t),
                        selectedColor: t.color.withAlpha(31),
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _type == t
                              ? t.color
                              : context.colors.onSurfaceVariant,
                        ),
                        side: BorderSide(
                          color: _type == t
                              ? t.color
                              : context.colors.outlineVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ExceptionDayField(
                  label: context.tr(
                    _isDayOff ? 'exceptions.day' : 'notes.date',
                  ),
                  placeholder: context.tr('attendance.select_date'),
                  initialValue: _date,
                  onChanged: (d) => _date = d,
                  validator: (d) =>
                      d == null ? context.tr('common.required') : null,
                ),
                if (!_isDayOff) ...[
                  const SizedBox(height: 16),
                  TimePickerFormField(
                    key: ValueKey(_type),
                    label: context.tr(timeLabelKey),
                    placeholder: context.tr('add_employee.select_time'),
                    initialValue: _time,
                    onChanged: (t) => _time = t,
                    validator: (t) =>
                        t == null ? context.tr('common.required') : null,
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  context.tr('exceptions.reason'),
                  style: Styles.textStyle13,
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _reason,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? context.tr('common.required')
                      : null,
                  decoration: appInputDecoration(
                    context,
                    hintText: context.tr('exceptions.reason_hint'),
                  ),
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
