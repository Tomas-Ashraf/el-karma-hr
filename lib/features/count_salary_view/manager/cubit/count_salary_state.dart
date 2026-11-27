import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';

enum CountSalaryStatus {
  loadingEmployees,
  ready,
  loadingRecords,
  success,
  failure,
}

class CountSalaryState {
  const CountSalaryState({
    required this.status,
    this.employees = const [],
    this.selected,
    this.records = const [],
    this.isCalculating = false,

    this.message,
    this.statuses = const {},
  });

  final CountSalaryStatus status;
  final List<EmployeeModel> employees;
  final EmployeeModel? selected;
  final List<RecordPreview> records;

  final bool isCalculating;
  final String? message;
  final Map<String, SalaryStatus> statuses;
  CountSalaryState copyWith({
    CountSalaryStatus? status,
    List<EmployeeModel>? employees,
    EmployeeModel? selected,
    List<RecordPreview>? records,
    bool? isCalculating,
    String? message,
    Map<String, SalaryStatus>? statuses,
  }) {
    return CountSalaryState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      selected: selected ?? this.selected,
      records: records ?? this.records,
      isCalculating: isCalculating ?? this.isCalculating,
      message: message,
      statuses: statuses ?? this.statuses,
    );
  }
}
