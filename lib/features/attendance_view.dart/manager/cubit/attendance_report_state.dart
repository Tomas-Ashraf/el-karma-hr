import 'package:el_karma_ph/features/attendance_view.dart/models/attendance_entry.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/settings_view/models/attendance_settings.dart';

enum AttendanceReportStatus {
  loadingEmployees,
  ready,
  calculating,
  success,
  failure,
}

enum RecordSaveStatus { idle, saving, saved, failed }

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
    this.settings,
    this.saveStatus = RecordSaveStatus.idle,
    this.message,
  });

  final AttendanceReportStatus status;
  final List<EmployeeModel> employees;
  final AttendanceFilter? filter;
  final List<AttendanceEntry> entries;

  final AttendanceSettings? settings;
  final RecordSaveStatus saveStatus;
  final String? message;

  AttendanceReportState copyWith({
    AttendanceReportStatus? status,
    List<EmployeeModel>? employees,
    AttendanceFilter? filter,
    List<AttendanceEntry>? entries,
    AttendanceSettings? settings,
    RecordSaveStatus? saveStatus,
    String? message,
  }) {
    return AttendanceReportState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      filter: filter ?? this.filter,
      entries: entries ?? this.entries,
      settings: settings ?? this.settings,
      saveStatus: saveStatus ?? this.saveStatus,
      message: message,
    );
  }
}
