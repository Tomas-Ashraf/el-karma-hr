import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/employee_details_view/manager/cubit/employee_details_cubit.dart';
import 'package:el_karma_ph/features/employee_details_view/manager/cubit/employee_details_state.dart';
import 'package:el_karma_ph/features/employee_details_view/presentation/widgets/details_info_card_widget.dart';
import 'package:el_karma_ph/features/employee_details_view/presentation/widgets/edit_dialogs_widget.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeDetailsViewBody extends StatelessWidget {
  const EmployeeDetailsViewBody({super.key});

  static final _phoneFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
    LengthLimitingTextInputFormatter(15),
  ];
  static final _salaryFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ];
  static final _deviceFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(9),
  ];

  Map<String, String> _userTypes(BuildContext c) => {
    'admin': c.tr('add_employee.type_admin'),
    'operator': c.tr('add_employee.type_operator'),
    'employee': c.tr('add_employee.type_employee'),
  };

  Map<String, String> _payments(BuildContext c) => {
    'instapay': c.tr('add_employee.pay_instapay'),
    'wallet': c.tr('add_employee.pay_wallet'),
    'cash': c.tr('add_employee.pay_cash'),
  };

  Map<String, String> _statuses(BuildContext c) => {
    'active': c.tr('employees.status_active'),
    'inactive': c.tr('employees.status_inactive'),
  };

  String? _required(BuildContext c, String? v) =>
      v == null || v.trim().isEmpty ? c.tr('common.required') : null;

  String? _validatePhone(BuildContext c, String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return c.tr('common.required');
    if (digits.length < 8 || digits.length > 15) {
      return c.tr('add_employee.invalid_phone');
    }
    return null;
  }

  String? _validateSalary(BuildContext c, String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return c.tr('common.required');
    final amount = double.tryParse(text);
    if (amount == null || amount < 0) return c.tr('settings.invalid_amount');
    return null;
  }

  String? _validateDeviceId(BuildContext c, String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return c.tr('common.required');
    final id = int.tryParse(text);
    if (id == null || id < 0) return c.tr('settings.invalid_number');
    return null;
  }

  String _editTitle(BuildContext c, String field) =>
      c.tr('employee_details.edit_title', args: {'field': field});

  Future<void> _editText(
    BuildContext context, {
    required String label,
    required String key,
    required String initial,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    TextCapitalization capitalization = TextCapitalization.none,
    String? suffixText,
    Object Function(String)? parse,
  }) async {
    final cubit = context.read<EmployeeDetailsCubit>();
    final result = await showEditTextDialog(
      context,
      title: _editTitle(context, label),
      initialValue: initial,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      textCapitalization: capitalization,
      suffixText: suffixText,
    );
    if (result == null || result == initial) return;
    cubit.update({key: parse == null ? result : parse(result)});
  }

  Future<void> _editDropdown(
    BuildContext context, {
    required String label,
    required String key,
    required Map<String, String> items,
    required String current,
  }) async {
    final cubit = context.read<EmployeeDetailsCubit>();
    final result = await showEditDropdownDialog(
      context,
      title: _editTitle(context, label),
      items: items,
      initialValue: current,
    );
    if (result == null || result == current) return;
    cubit.update({key: result});
  }

  Future<void> _editShift(
    BuildContext context,
    EmployeeModel employee,
    int index,
  ) async {
    final cubit = context.read<EmployeeDetailsCubit>();
    final number = index + 1;
    final title = _editTitle(
      context,
      context.tr('add_employee.shift_title', args: {'n': '$number'}),
    );
    final result = await showEditShiftDialog(
      context,
      title: title,
      number: number,
      initial: employee.shifts[index],
    );
    if (result == null) return;
    cubit.update({
      'shift${number}_start': Timestamp.fromDate(result.start),
      'shift${number}_end': Timestamp.fromDate(result.end),
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 600.0;

    return BlocConsumer<EmployeeDetailsCubit, EmployeeDetailsState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          (current.status == EmployeeDetailsStatus.saved ||
              current.status == EmployeeDetailsStatus.failure),
      listener: (context, state) {
        final isSaved = state.status == EmployeeDetailsStatus.saved;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                context.tr(
                  isSaved
                      ? 'employee_details.updated'
                      : (state.message ?? 'error.generic'),
                ),
              ),
              backgroundColor: isSaved ? Colors.green : Colors.red,
            ),
          );
      },
      builder: (context, state) {
        final e = state.employee;
        final isSaving = state.status == EmployeeDetailsStatus.saving;
        final userTypes = _userTypes(context);
        final payments = _payments(context);
        final statuses = _statuses(context);
        final egp = context.tr('common.egp');
        final salaryText = e.salary % 1 == 0
            ? e.salary.toInt().toString()
            : e.salary.toString();

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                children: [
                  if (isSaving) const LinearProgressIndicator(minHeight: 2),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.05,
                        vertical: screenSize.height * 0.02,
                      ),
                      children: [
                        _Header(employee: e),
                        const SizedBox(height: 20),
                        DetailsInfoCard(
                          label: context.tr('add_employee.name'),
                          value: e.name,
                          onEdit: () => _editText(
                            context,
                            label: context.tr('add_employee.name'),
                            key: 'name',
                            initial: e.name,
                            validator: (v) => _required(context, v),
                            capitalization: TextCapitalization.words,
                          ),
                        ),
                        DetailsInfoCard(
                          label: context.tr('add_employee.email'),
                          value: e.email,
                        ),
                        DetailsInfoCard(
                          label: context.tr('add_employee.job'),
                          value: e.job,
                          onEdit: () => _editText(
                            context,
                            label: context.tr('add_employee.job'),
                            key: 'job',
                            initial: e.job,
                            validator: (v) => _required(context, v),
                            capitalization: TextCapitalization.words,
                          ),
                        ),
                        DetailsInfoCard(
                          label: context.tr('add_employee.user_type'),
                          value: userTypes[e.userType] ?? e.userType,
                          onEdit: () => _editDropdown(
                            context,
                            label: context.tr('add_employee.user_type'),
                            key: 'user_type',
                            items: userTypes,
                            current: e.userType,
                          ),
                        ),
                        DetailsInfoCard(
                          label: context.tr('add_employee.phone'),
                          value: e.phoneNumber,
                          onEdit: () => _editText(
                            context,
                            label: context.tr('add_employee.phone'),
                            key: 'phone_number',
                            initial: e.phoneNumber,
                            validator: (v) => _validatePhone(context, v),
                            keyboardType: TextInputType.phone,
                            formatters: _phoneFormatters,
                          ),
                        ),
                        DetailsInfoCard(
                          label: context.tr('add_employee.salary'),
                          value: '$salaryText $egp',
                          onEdit: () => _editText(
                            context,
                            label: context.tr('add_employee.salary'),
                            key: 'salary',
                            initial: salaryText,
                            validator: (v) => _validateSalary(context, v),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            formatters: _salaryFormatters,
                            suffixText: egp,
                            parse: (v) => double.parse(v),
                          ),
                        ),
                        DetailsInfoCard(
                          label: context.tr('add_employee.payment_method'),
                          value: payments[e.paymentMethod] ?? e.paymentMethod,
                          onEdit: () => _editDropdown(
                            context,
                            label: context.tr('add_employee.payment_method'),
                            key: 'payment_method',
                            items: payments,
                            current: e.paymentMethod,
                          ),
                        ),
                        DetailsInfoCard(
                          label: context.tr('add_employee.status'),
                          value: e.isActive
                              ? statuses['active']!
                              : statuses['inactive']!,
                          onEdit: () => _editDropdown(
                            context,
                            label: context.tr('add_employee.status'),
                            key: 'status',
                            items: statuses,
                            current: e.isActive ? 'active' : 'inactive',
                          ),
                        ),
                        DetailsInfoCard(
                          label: context.tr('add_employee.device_id'),
                          value: '${e.deviceId}',
                          onEdit: () => _editText(
                            context,
                            label: context.tr('add_employee.device_id'),
                            key: 'device_id',
                            initial: '${e.deviceId}',
                            validator: (v) => _validateDeviceId(context, v),
                            keyboardType: TextInputType.number,
                            formatters: _deviceFormatters,
                            parse: (v) => int.parse(v),
                          ),
                        ),
                        for (final (index, shift) in e.shifts.indexed)
                          DetailsInfoCard(
                            label: context.tr(
                              'add_employee.shift_title',
                              args: {'n': '${index + 1}'},
                            ),
                            value:
                                '${TimeOfDay.fromDateTime(shift.start).format(context)}'
                                ' - '
                                '${TimeOfDay.fromDateTime(shift.end).format(context)}',
                            onEdit: () => _editShift(context, e, index),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.employee});

  final EmployeeModel employee;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kPrimaryBlue.withAlpha(31),
            shape: BoxShape.circle,
          ),
          child: Text(
            employee.initials,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          employee.name,
          style: Styles.textStyle20,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(employee.job, style: Styles.textStyle14),
      ],
    );
  }
}
