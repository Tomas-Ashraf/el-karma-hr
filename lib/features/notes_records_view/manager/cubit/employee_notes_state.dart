import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';

enum EmployeeNotesStatus { loadingEmployees, ready, loading, success, failure }

class EmployeeNotesState {
  const EmployeeNotesState({
    required this.status,
    this.employees = const [],
    this.filter,
    this.items = const [],
    this.message,
  });

  final EmployeeNotesStatus status;
  final List<EmployeeModel> employees;
  final NotesFilter? filter;
  final List<EmployeeAdjustment> items;
  final String? message;

  EmployeeNotesState copyWith({
    EmployeeNotesStatus? status,
    List<EmployeeModel>? employees,
    NotesFilter? filter,
    List<EmployeeAdjustment>? items,
    String? message,
  }) {
    return EmployeeNotesState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      filter: filter ?? this.filter,
      items: items ?? this.items,
      message: message,
    );
  }
}
