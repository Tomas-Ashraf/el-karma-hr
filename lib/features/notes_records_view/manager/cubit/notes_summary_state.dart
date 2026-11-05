import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';

enum NotesSummaryStatus {
  loadingEmployees,
  ready,
  calculating,
  success,
  failure,
}

class NotesSummaryState {
  const NotesSummaryState({
    required this.status,
    this.employees = const [],
    this.period,
    this.summary,
    this.message,
  });

  final NotesSummaryStatus status;
  final List<EmployeeModel> employees;
  final NotesPeriod? period;
  final NotesSummary? summary;
  final String? message;

  NotesSummaryState copyWith({
    NotesSummaryStatus? status,
    List<EmployeeModel>? employees,
    NotesPeriod? period,
    NotesSummary? summary,
    String? message,
  }) {
    return NotesSummaryState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      period: period ?? this.period,
      summary: summary ?? this.summary,
      message: message,
    );
  }
}
