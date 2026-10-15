import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/settings_view/manager/cubit/attendance_settings_cubit.dart';
import 'package:el_karma_ph/features/settings_view/manager/cubit/attendance_settings_state.dart';
import 'package:el_karma_ph/features/settings_view/models/attendance_settings.dart';
import 'package:el_karma_ph/features/settings_view/presentation/widgets/settings_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceSettingsSection extends StatelessWidget {
  const AttendanceSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceSettingsCubit, AttendanceSettingsState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          (current.status == AttendanceSettingsStatus.saved ||
              (current.status == AttendanceSettingsStatus.failure &&
                  current.settings != null)),
      listener: (context, state) {
        final isSaved = state.status == AttendanceSettingsStatus.saved;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSaved
                  ? 'Settings saved successfully.'
                  : (state.message ?? 'Something went wrong.'),
            ),
            backgroundColor: isSaved ? Colors.green : Colors.red,
          ),
        );
      },
      builder: (context, state) {
        final settings = state.settings;

        Widget content;
        if (settings != null) {
          content = _AttendanceSettingsForm(
            initial: settings,
            isSaving: state.status == AttendanceSettingsStatus.saving,
          );
        } else if (state.status == AttendanceSettingsStatus.failure) {
          content = _LoadError(
            message: state.message ?? 'Something went wrong.',
            onRetry: () => context.read<AttendanceSettingsCubit>().load(),
          );
        } else {
          content = const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return SettingsSectionCard(
          title: 'Attendance Settings',
          child: content,
        );
      },
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message, style: Styles.textStyle14, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

class _AttendanceSettingsForm extends StatefulWidget {
  const _AttendanceSettingsForm({
    required this.initial,
    required this.isSaving,
  });

  final AttendanceSettings initial;
  final bool isSaving;

  @override
  State<_AttendanceSettingsForm> createState() =>
      _AttendanceSettingsFormState();
}

class _AttendanceSettingsFormState extends State<_AttendanceSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _lateController;
  late final TextEditingController _leaveEarlyController;
  late final TextEditingController _deductionController;

  @override
  void initState() {
    super.initState();
    _lateController = TextEditingController(
      text: '${widget.initial.lateMinutes}',
    );
    _leaveEarlyController = TextEditingController(
      text: '${widget.initial.leaveEarlyMinutes}',
    );
    _deductionController = TextEditingController(
      text: _formatAmount(widget.initial.deductionPerMinute),
    );
  }

  @override
  void dispose() {
    _lateController.dispose();
    _leaveEarlyController.dispose();
    _deductionController.dispose();
    super.dispose();
  }

  static String _formatAmount(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  String? _validateMinutes(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Required';
    final minutes = int.tryParse(text);
    if (minutes == null || minutes < 0) return 'Enter a valid number';
    if (minutes > 1440) return 'Max is 1440 minutes';
    return null;
  }

  String? _validateAmount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Required';
    final amount = double.tryParse(text);
    if (amount == null || amount < 0) return 'Enter a valid amount';
    return null;
  }

  void _submit() {
    if (widget.isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    context.read<AttendanceSettingsCubit>().save(
      AttendanceSettings(
        lateMinutes: int.parse(_lateController.text.trim()),
        leaveEarlyMinutes: int.parse(_leaveEarlyController.text.trim()),
        deductionPerMinute: double.parse(_deductionController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final minutesFormatters = <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ];

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsInputField(
            label: 'Late time (mins)',
            helperText: 'Grace period before an employee is counted as late',
            suffixText: 'min',
            controller: _lateController,
            validator: _validateMinutes,
            inputFormatters: minutesFormatters,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          SettingsInputField(
            label: 'Leave early time (mins)',
            helperText: 'How early an employee can leave without a deduction',
            suffixText: 'min',
            controller: _leaveEarlyController,
            validator: _validateMinutes,
            inputFormatters: minutesFormatters,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          SettingsInputField(
            label: 'Salary deduction value',
            helperText: 'Deduction in EGP for each minute of lateness',
            suffixText: 'EGP',
            controller: _deductionController,
            validator: _validateAmount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          ButtonWidget(
            width: double.infinity,
            height: 52,
            onPressed: _submit,
            backgroundColor: kPrimaryBlue,
            foregroundColor: Colors.white,
            text: widget.isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Changes', style: Styles.textStyle16),
          ),
        ],
      ),
    );
  }
}
