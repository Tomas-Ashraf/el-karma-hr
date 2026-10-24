import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:flutter/material.dart';

class ShiftEntry {
  final Key key = UniqueKey();
  TimeOfDay? start;
  TimeOfDay? end;
}

class ShiftFields extends StatelessWidget {
  const ShiftFields({
    super.key,
    required this.number,
    required this.entry,
    this.onRemove,
  });

  final int number;
  final ShiftEntry entry;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final args = {'n': '$number'};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onRemove != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('add_employee.shift_title', args: args),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.tr('add_employee.remove_shift'),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: onRemove,
              ),
            ],
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TimePickerFormField(
                label: context.tr('add_employee.shift_start', args: args),
                placeholder: context.tr('add_employee.select_time'),
                initialValue: entry.start,
                onChanged: (time) => entry.start = time,
                validator: (time) =>
                    time == null ? context.tr('common.required') : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TimePickerFormField(
                label: context.tr('add_employee.shift_end', args: args),
                placeholder: context.tr('add_employee.select_time'),
                initialValue: entry.end,
                onChanged: (time) => entry.end = time,
                validator: (time) {
                  if (time == null) return context.tr('common.required');
                  if (entry.start != null && entry.start == time) {
                    return context.tr('add_employee.shift_same_time');
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
