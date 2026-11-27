import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:el_karma_ph/features/attendance_exception_view/models/attendance_exception_models.dart';
import 'package:el_karma_ph/features/attendance_exception_view/presentation/widgets/exception_card.dart';
import 'package:flutter/material.dart';

/// بيضيف أو يعدّل إذن/إجازة. بيرجّع الـ exception الجديد أو null.
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

  late ExceptionType _type = widget.initial?.type ?? ExceptionType.lateArrival;
  late DateTime? _date = widget.initial?.date;
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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    Navigator.of(context).pop(
      AttendanceException(
        id: widget.initial?.id ?? now.microsecondsSinceEpoch.toString(),
        employeeId: widget.employeeId,
        type: _type,
        // الإجازة بتختار يومها، والإذن بيتسجل على النهارده (أو يومه القديم)
        date: _isDayOff ? _date! : (widget.initial?.date ?? today),
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
                if (_isDayOff)
                  _DayPickerField(
                    label: context.tr('exceptions.day'),
                    placeholder: context.tr('attendance.select_date'),
                    initialValue: _date,
                    onChanged: (d) => _date = d,
                    validator: (d) =>
                        d == null ? context.tr('common.required') : null,
                  )
                else
                  TimePickerFormField(
                    key: ValueKey(_type),
                    label: context.tr(timeLabelKey),
                    placeholder: context.tr('add_employee.select_time'),
                    initialValue: _time,
                    onChanged: (t) => _time = t,
                    validator: (t) =>
                        t == null ? context.tr('common.required') : null,
                  ),
                const SizedBox(height: 16),
                Text(context.tr('exceptions.reason'), style: Styles.textStyle13),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _reason,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
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

/// زي DatePickerFormField بس بيسمح بأيام جاية (الإجازة ممكن تتحدد مسبقًا).
class _DayPickerField extends FormField<DateTime> {
  _DayPickerField({
    required String label,
    required String placeholder,
    required ValueChanged<DateTime> onChanged,
    super.initialValue,
    super.validator,
  }) : super(
         builder: (state) {
           final context = state.context;
           final value = state.value;

           Future<void> pick() async {
             final now = DateTime.now();
             final picked = await showDatePicker(
               context: context,
               initialDate: value ?? now,
               firstDate: DateTime(2020),
               lastDate: DateTime(now.year + 2, 12, 31),
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
