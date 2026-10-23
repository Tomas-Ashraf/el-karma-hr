import 'package:el_karma_ph/core/utils/employee/employee_field.dart';
import 'package:el_karma_ph/core/widgets/New%20folder/app_page_bar.dart';
import 'package:el_karma_ph/core/widgets/New%20folder/primary_button.dart';
import 'package:flutter/material.dart';

import '../widgets/labeled_form_field.dart';

/// Pops with the entered values (`Map<EmployeeField, String>`), or null if cancelled.
class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _values = <EmployeeField, String>{};

  void _submit() {
    final form = _formKey.currentState!;
    if (!form.validate()) return;

    form.save();
    Navigator.pop(context, Map<EmployeeField, String>.of(_values));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppPageBar(title: 'Add Member'),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              for (final field in EmployeeField.values)
                LabeledFormField(
                  field: field,
                  onSaved: (value) => _values[field] = value,
                ),
              const SizedBox(height: 6),
              PrimaryButton(label: 'Add Member', onTap: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
