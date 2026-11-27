import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:flutter/material.dart' show TimeOfDay;

enum ExceptionType { lateArrival, earlyLeave, dayOff }

class AttendanceException {
  const AttendanceException({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.date,
    this.time,
    this.reason = '',
  });

  final String id;
  final String employeeId;
  final ExceptionType type;

  /// اليوم اللي الإذن/الإجازة ليه.
  final DateTime date;

  /// وقت الحضور المتأخر أو الانصراف المبكر (null في حالة الإجازة).
  final TimeOfDay? time;
  final String reason;
}

class ExceptionsFilter {
  const ExceptionsFilter({
    required this.employee,
    required this.from,
    required this.to,
  });

  final EmployeeModel employee;
  final DateTime from;
  final DateTime to;
}
