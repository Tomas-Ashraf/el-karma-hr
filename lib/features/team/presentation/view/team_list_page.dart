import 'package:el_karma_ph/core/app_colors.dart';
import 'package:el_karma_ph/core/utils/employee/employee.dart';
import 'package:el_karma_ph/core/utils/employee/employee_field.dart';
import 'package:el_karma_ph/core/widgets/New%20folder/app_page_bar.dart';
import 'package:el_karma_ph/core/widgets/New%20folder/app_snack_bar.dart';
import 'package:el_karma_ph/core/widgets/New%20folder/primary_button.dart';
import 'package:el_karma_ph/features/team/presentation/view_model/spam_data/functions.dart';
import 'package:el_karma_ph/features/team/presentation/view_model/spam_data/jobs.dart';
import 'package:el_karma_ph/features/team/presentation/view_model/spam_data/names.dart';
import 'package:el_karma_ph/features/team/presentation/widgets/search.dart';
import 'package:el_karma_ph/features/team/presentation/widgets/test_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/employee_tile.dart';
import 'add_member_page.dart';
import 'employee_details_page.dart';

enum TestDataAction { add10, add50, add200, deleteAll }

class TeamListPage extends StatefulWidget {
  const TeamListPage({super.key});

  @override
  State<TeamListPage> createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamListPage> {
  Future<void> _openDetails(Employee employee) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeDetailsPage(employee: employee),
      ),
    );
    if (mounted) setState(() {}); // refresh name / job after edits
  }

  Future<void> _addMember() async {
    final values = await Navigator.push<Map<EmployeeField, String>>(
      context,
      MaterialPageRoute(builder: (_) => const AddMemberPage()),
    );
    if (values == null) return;

    setState(() => employees.add(employeeFromValues('${++lastId}', values)));
    if (mounted) showAppSnackBar(context, 'Member added');
  }

  void _delete(Employee employee) {
    setState(() => employees.remove(employee));
    showAppSnackBar(context, 'Member deleted');
  }

  void _addFake(int count) {
    for (var i = 0; i < count; i++) {
      employees.add(fakeEmployee(++lastId));
    }
  }

  void _onTestData(TestDataAction action) {
    setState(() {
      switch (action) {
        case TestDataAction.add10:
          _addFake(10);
        case TestDataAction.add50:
          _addFake(50);
        case TestDataAction.add200:
          _addFake(200);
        case TestDataAction.deleteAll:
          employees.clear();
      }
    });
    showAppSnackBar(context, 'Total members: ${employees.length}');
  }

  @override
  Widget build(BuildContext context) {
    final employees = visible;

    return Scaffold(
      appBar: const AppPageBar(title: 'Team Members', showBack: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 6),
              if (kDebugMode)
                Align(
                  alignment: Alignment.centerRight,
                  child: TestDataMenu(onSelected: _onTestData),
                ),
              SearchField(onChanged: (v) => setState(() => query = v)),
              const SizedBox(height: 8),
              Expanded(
                child: employees.isEmpty
                    ? const Center(
                        child: Text(
                          'No team members found',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: employees.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: AppColors.line),
                        itemBuilder: (_, i) => EmployeeTile(
                          employee: employees[i],
                          onTap: () => _openDetails(employees[i]),
                          onDelete: () => _delete(employees[i]),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: PrimaryButton(label: 'Add Member', onTap: _addMember),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
