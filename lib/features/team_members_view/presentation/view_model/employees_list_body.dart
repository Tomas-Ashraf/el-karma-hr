import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/team_members_view/presentation/widgets/employee_item_widget.dart';
import 'package:el_karma_ph/features/team_members_view/presentation/widgets/employee_tile_widget.dart';
import 'package:el_karma_ph/features/team_members_view/presentation/widgets/search_field_widget.dart';
import 'package:flutter/material.dart';

class EmployeesListBody extends StatefulWidget {
  const EmployeesListBody({super.key});

  @override
  State<EmployeesListBody> createState() => _EmployeesListBodyState();
}

class _EmployeesListBodyState extends State<EmployeesListBody> {
  String _query = '';

  List<EmployeeItem> get _employees {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return sampleEmployees;
    return sampleEmployees
        .where(
          (e) =>
              e.name.toLowerCase().contains(query) ||
              e.job.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 700.0;
    final employees = _employees;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchFieldWidget(
                  hintText: context.tr('employees.search_hint'),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 16),
                Text(
                  '${context.tr('employees.count')}: 10',
                  style: Styles.textStyle14,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: employees.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          itemCount: employees.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) => EmployeeTileWidget(
                            employee: employees[index],
                            onTap: () {},
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                ButtonWidget(
                  width: double.infinity,
                  height: 52,
                  onPressed: () {},
                  backgroundColor: kPrimaryBlue,
                  foregroundColor: Colors.white,
                  text: Text(
                    context.tr('employees.add'),
                    style: Styles.textStyle16,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: kPrimaryBlue.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              size: 34,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(context.tr('employees.empty'), style: Styles.textStyle14),
        ],
      ),
    );
  }
}
