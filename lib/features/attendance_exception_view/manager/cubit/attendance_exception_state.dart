import 'package:el_karma_ph/features/attendance_exception_view/models/attendance_exception_models.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';

enum ExceptionsStatus { loadingEmployees, ready, loading, success, failure }

class AttendanceExceptionState {
  const AttendanceExceptionState({
    required this.status,
    this.employees = const [],
    this.filter,
    this.items = const [],
    this.message,
  });

  final ExceptionsStatus status;
  final List<EmployeeModel> employees;
  final ExceptionsFilter? filter;
  final List<AttendanceException> items;
  final String? message;

  AttendanceExceptionState copyWith({
    ExceptionsStatus? status,
    List<EmployeeModel>? employees,
    ExceptionsFilter? filter,
    List<AttendanceException>? items,
    String? message,
  }) {
    return AttendanceExceptionState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      filter: filter ?? this.filter,
      items: items ?? this.items,
      message: message,
    );
  }
}
