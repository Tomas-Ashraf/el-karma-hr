import 'package:el_karma_ph/core/utils/employee/employee.dart';
import 'package:el_karma_ph/core/utils/employee/employee_field.dart';
import 'package:el_karma_ph/core/widgets/New%20folder/app_page_bar.dart';
import 'package:el_karma_ph/core/widgets/New%20folder/app_snack_bar.dart';
import 'package:el_karma_ph/features/employees_view/presentation/widgets/add_shift_button.dart';
import 'package:el_karma_ph/features/employees_view/presentation/widgets/header.dart';
import 'package:flutter/material.dart';

import '../widgets/editable_info_card.dart';

class EmployeeDetailsPage extends StatefulWidget {
  const EmployeeDetailsPage({super.key, required this.employee});

  final Employee employee;

  @override
  State<EmployeeDetailsPage> createState() => _EmployeeDetailsPageState();
}

class _EmployeeDetailsPageState extends State<EmployeeDetailsPage> {
  /// Key of the card being edited: a field name ("email") or "shift-0", "shift-1"...
  String? _editing;
  final List<String> _extraShifts = [];
  final Map<EmployeeField, String> _values = {};

  Employee get _employee => widget.employee;

  void _save(String key, String value) {
    final text = value.trim();
    if (text.isEmpty) {
      showAppSnackBar(context, 'This field is required');
      return;
    }

    setState(() {
      if (key.startsWith('shift-')) {
        _extraShifts[int.parse(key.substring(6))] = text;
      } else {
        _values[EmployeeField.values.byName(key)] = text;
      }
      _editing = null;
    });
    showAppSnackBar(context, 'Saved');
  }

  void _addShift() {
    setState(() {
      _extraShifts.add('00:00 AM - 00:00 PM');
      _editing = 'shift-${_extraShifts.length - 1}';
    });
  }

  Widget _card({
    required String key,
    required String label,
    required String value,
    List<String>? options,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return EditableInfoCard(
      key: ValueKey(key),
      label: label,
      value: value,
      options: options,
      keyboardType: keyboardType,
      isEditing: _editing == key,
      onEdit: () => setState(() => _editing = key),
      onSave: (v) => _save(key, v),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppPageBar(title: 'Member Details'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Header(employee: _employee),
            for (final field in EmployeeField.values)
              _card(
                key: field.name,
                label: field.label,
                value: _values[field] ?? '',
                options: field.options,
              ),
            for (var i = 0; i < _extraShifts.length; i++)
              _card(
                key: 'shift-$i',
                label: 'Shift ${i + 2} period',
                value: _extraShifts[i],
              ),
            AddShiftButton(onTap: _addShift),
          ],
        ),
      ),
    );
  }
}
