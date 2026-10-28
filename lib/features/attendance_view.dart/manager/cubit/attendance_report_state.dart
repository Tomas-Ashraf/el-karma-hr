import 'package:el_karma_ph/features/attendance_view.dart/models/attendance_entry.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';

enum AttendanceReportStatus {
  loadingEmployees,
  ready,
  calculating,
  success,
  failure,
}

class AttendanceFilter {
  const AttendanceFilter({
    required this.employee,
    required this.from,
    required this.to,
  });

  final EmployeeModel employee;
  final DateTime from;
  final DateTime to;
}

class AttendanceReportState {
  const AttendanceReportState({
    required this.status,
    this.employees = const [],
    this.filter,
    this.entries = const [],
    this.message,
  });

  final AttendanceReportStatus status;
  final List<EmployeeModel> employees;
  final AttendanceFilter? filter;
  final List<AttendanceEntry> entries;
  final String? message;

  AttendanceReportState copyWith({
    AttendanceReportStatus? status,
    List<EmployeeModel>? employees,
    AttendanceFilter? filter,
    List<AttendanceEntry>? entries,
    String? message,
  }) {
    return AttendanceReportState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      filter: filter ?? this.filter,
      entries: entries ?? this.entries,
      message: message,
    );
  }
}
