import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_dummy_data.dart';
import 'package:el_karma_ph/features/count_salary_view/presentation/widgets/message.dart';
import 'package:el_karma_ph/features/count_salary_view/presentation/widgets/records_list.dart';
import 'package:el_karma_ph/features/count_salary_view/presentation/widgets/salary_employee_dialog.dart';
import 'package:flutter/material.dart';

class CountSalaryViewBody extends StatefulWidget {
  const CountSalaryViewBody({super.key});

  @override
  State<CountSalaryViewBody> createState() => _CountSalaryViewBodyState();
}

class _CountSalaryViewBodyState extends State<CountSalaryViewBody> {
  SalaryEmployee? _selected;

  @override
  void initState() {
    super.initState();
    // أول ما الشاشة تفتح نطلب اختيار الموظف
    WidgetsBinding.instance.addPostFrameCallback((_) => _pickEmployee());
  }

  Future<void> _pickEmployee() async {
    if (!mounted) return;
    final result = await showSalaryEmployeeDialog(context, initial: _selected);
    if (result != null && mounted) setState(() => _selected = result);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 600.0;
    final employee = _selected;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.015,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EmployeeButton(
                  label: employee?.name ?? context.tr('salary.select_employee'),
                  onTap: _pickEmployee,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: employee == null
                      ? const Message()
                      : RecordsList(employee: employee),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmployeeButton extends StatelessWidget {
  const _EmployeeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.person_search_rounded, color: kPrimaryBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.tune_rounded, size: 20, color: kPrimaryBlue),
            ],
          ),
        ),
      ),
    );
  }
}
