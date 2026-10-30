import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/weekdays.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/add_employee_view/manager/cubit/add_employee_cubit.dart';
import 'package:el_karma_ph/features/add_employee_view/models/add_employee_model.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/shift_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddEmployeeViewBody extends StatefulWidget {
  const AddEmployeeViewBody({super.key});

  @override
  State<AddEmployeeViewBody> createState() => _AddEmployeeViewBodyState();
}

class _AddEmployeeViewBodyState extends State<AddEmployeeViewBody> {
  static const _maxShifts = 3;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _jobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _salaryController = TextEditingController();
  final _deviceIdController = TextEditingController();

  String? _userType;
  String? _paymentMethod;
  String _status = 'active';
  final List<ShiftEntry> _shifts = [ShiftEntry()];
  String? _dayOff;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _jobController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.tr('common.required');
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.tr('common.required');
    if (!_emailRegex.hasMatch(text)) {
      return context.tr('error.enter_valid_email');
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return context.tr('common.required');
    if (digits.length < 8 || digits.length > 15) {
      return context.tr('add_employee.invalid_phone');
    }
    return null;
  }

  String? _validateSalary(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.tr('common.required');
    final amount = double.tryParse(text);
    if (amount == null || amount < 0) {
      return context.tr('settings.invalid_amount');
    }
    return null;
  }

  String? _validateDeviceId(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.tr('common.required');
    final id = int.tryParse(text);
    if (id == null || id < 0) return context.tr('settings.invalid_number');
    return null;
  }

  String? _requiredSelection(String? value) {
    return value == null ? context.tr('common.required') : null;
  }

  List<ShiftRange> _buildShifts() {
    final now = DateTime.now();

    return _shifts.map((shift) {
      final start = DateTime(
        now.year,
        now.month,
        now.day,
        shift.start!.hour,
        shift.start!.minute,
      );
      var end = DateTime(
        now.year,
        now.month,
        now.day,
        shift.end!.hour,
        shift.end!.minute,
      );
      if (!end.isAfter(start)) {
        end = DateTime(
          now.year,
          now.month,
          now.day + 1,
          shift.end!.hour,
          shift.end!.minute,
        );
      }
      return ShiftRange(start: start, end: end);
    }).toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(name: _nameController.text.trim()),
    );
    if (confirmed != true || !mounted) return;

    context.read<AddEmployeeCubit>().submit(
      NewEmployee(
        name: _nameController.text,
        email: _emailController.text,
        job: _jobController.text,
        userType: _userType!,
        phoneNumber: _phoneController.text,
        salary: double.parse(_salaryController.text.trim()),
        paymentMethod: _paymentMethod!,
        status: _status,
        deviceId: int.parse(_deviceIdController.text.trim()),
        shifts: _buildShifts(),
        dayOff: _dayOff,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 600.0;
    const gap = SizedBox(height: 16);

    return BlocListener<AddEmployeeCubit, AddEmployeeState>(
      listener: (context, state) {
        if (state is AddEmployeeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('add_employee.success')),
              backgroundColor: Colors.green,
            ),
          );
          final router = GoRouter.of(context);
          router.canPop()
              ? router.pop(true)
              : router.go(AppRouter.kDashboardView);
        } else if (state is AddEmployeeFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr(state.errorMessage)),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.02,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabeledTextField(
                      label: context.tr('add_employee.name'),
                      controller: _nameController,
                      validator: _required,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    ),
                    gap,
                    LabeledTextField(
                      label: context.tr('add_employee.email'),
                      controller: _emailController,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    gap,
                    LabeledTextField(
                      label: context.tr('add_employee.job'),
                      controller: _jobController,
                      validator: _required,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    ),
                    gap,
                    LabeledDropdown<String>(
                      label: context.tr('add_employee.user_type'),
                      hint: context.tr('add_employee.select'),
                      initialValue: _userType,
                      items: {
                        'admin': context.tr('add_employee.type_admin'),
                        'operator': context.tr('add_employee.type_operator'),
                        'employee': context.tr('add_employee.type_employee'),
                      },
                      validator: _requiredSelection,
                      onChanged: (value) => _userType = value,
                    ),
                    gap,
                    LabeledTextField(
                      label: context.tr('add_employee.phone'),
                      controller: _phoneController,
                      validator: _validatePhone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      textInputAction: TextInputAction.next,
                    ),
                    gap,
                    LabeledTextField(
                      label: context.tr('add_employee.salary'),
                      controller: _salaryController,
                      validator: _validateSalary,
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
                    gap,
                    LabeledDropdown<String>(
                      label: context.tr('add_employee.payment_method'),
                      hint: context.tr('add_employee.select'),
                      initialValue: _paymentMethod,
                      items: {
                        'instapay': context.tr('add_employee.pay_instapay'),
                        'wallet': context.tr('add_employee.pay_wallet'),
                        'cash': context.tr('add_employee.pay_cash'),
                      },
                      validator: _requiredSelection,
                      onChanged: (value) => _paymentMethod = value,
                    ),
                    gap,
                    LabeledDropdown<String>(
                      label: context.tr('add_employee.status'),
                      initialValue: _status,

                      items: {
                        'active': context.tr('employees.status_active'),
                        'inactive': context.tr('employees.status_inactive'),
                      },
                      onChanged: (value) => _status = value ?? _status,
                    ),
                    gap,
                    LabeledDropdown<String>(
                      label: context.tr('add_employee.day_off'),
                      hint: context.tr('add_employee.select'),
                      initialValue: _dayOff,
                      items: weekdayOptions(context),
                      validator: _requiredSelection,
                      onChanged: (value) => _dayOff = value,
                    ),
                    gap,
                    LabeledTextField(
                      label: context.tr('add_employee.device_id'),
                      controller: _deviceIdController,
                      validator: _validateDeviceId,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                      textInputAction: TextInputAction.done,
                    ),
                    gap,
                    for (final (index, shift) in _shifts.indexed) ...[
                      ShiftFields(
                        key: shift.key,
                        number: index + 1,
                        entry: shift,
                        onRemove: index == 0
                            ? null
                            : () => setState(() => _shifts.remove(shift)),
                      ),
                      gap,
                    ],
                    if (_shifts.length < _maxShifts) ...[
                      OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _shifts.add(ShiftEntry())),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(context.tr('add_employee.add_shift')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimaryBlue,
                          side: const BorderSide(color: kPrimaryBlue),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      gap,
                    ],
                    const SizedBox(height: 8),
                    BlocBuilder<AddEmployeeCubit, AddEmployeeState>(
                      builder: (context, state) {
                        final isLoading = state is AddEmployeeLoading;
                        return ButtonWidget(
                          width: double.infinity,
                          height: 52,
                          onPressed: () {
                            if (isLoading) return;
                            _submit();
                          },
                          backgroundColor: kPrimaryBlue,
                          foregroundColor: Colors.white,
                          text: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  context.tr('add_employee.submit'),
                                  style: Styles.textStyle16,
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        context.tr('add_employee.confirm_title'),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Text(
        context.tr('add_employee.confirm_message', args: {'name': name}),
        style: Styles.textStyle14,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.tr('common.cancel')),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
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
