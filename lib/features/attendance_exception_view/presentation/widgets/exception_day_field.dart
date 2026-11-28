import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:flutter/material.dart';

class ExceptionDayField extends FormField<DateTime> {
  ExceptionDayField({
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
