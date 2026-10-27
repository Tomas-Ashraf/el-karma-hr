import 'dart:math' as math;

import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';

class DashboardStats {
  const DashboardStats({
    required this.checkedIn,
    required this.checkedOut,
    required this.late,
    required this.onTime,
  });

  final int checkedIn;
  final int checkedOut;
  final int late;
  final int onTime;
}

class ShiftAttendance {
  const ShiftAttendance({
    required this.employee,
    required this.shiftNumber,
    required this.shiftStart,
    required this.shiftEnd,
    required this.checkIn,
    required this.isLate,
    this.checkOut,
  });

  final EmployeeModel employee;
  final int shiftNumber;
  final DateTime shiftStart;
  final DateTime shiftEnd;
  final DateTime checkIn;
  final DateTime? checkOut;
  final bool isLate;

  DateTime get lastActivity => checkOut ?? checkIn;

  int get minutesLate {
    final minutes = checkIn.difference(shiftStart).inMinutes;
    return minutes < 0 ? 0 : minutes;
  }
}

class EmployeeDayStatus {
  const EmployeeDayStatus(this.employee, this.shifts);

  final EmployeeModel employee;

  final List<ShiftAttendance> shifts;

  bool get checkedOut => shifts.every((s) => s.checkOut != null);

  bool get isLate => shifts.any((s) => s.isLate);

  DateTime get firstCheckIn => shifts.first.checkIn;

  DateTime? get lastCheckOut => checkedOut ? shifts.last.checkOut : null;

  int get minutesLate =>
      shifts.where((s) => s.isLate).map((s) => s.minutesLate).fold(0, math.max);
}

class DashboardData {
  DashboardData._(this.recent, this.employees);

  factory DashboardData.fromRecords(List<ShiftAttendance> records) {
    final byEmployee = <String, List<ShiftAttendance>>{};
    for (final record in records) {
      byEmployee.putIfAbsent(record.employee.id, () => []).add(record);
    }

    final employees = byEmployee.values.map((shifts) {
      shifts.sort((a, b) => a.shiftStart.compareTo(b.shiftStart));
      return EmployeeDayStatus(shifts.first.employee, shifts);
    }).toList()..sort((a, b) => a.firstCheckIn.compareTo(b.firstCheckIn));

    final recent = [...records]
      ..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));

    return DashboardData._(recent, employees);
  }

  final List<ShiftAttendance> recent;

  final List<EmployeeDayStatus> employees;

  List<EmployeeDayStatus> get checkedIn => employees;
  List<EmployeeDayStatus> get checkedOut =>
      employees.where((e) => e.checkedOut).toList();
  List<EmployeeDayStatus> get late => employees.where((e) => e.isLate).toList();
  List<EmployeeDayStatus> get onTime =>
      employees.where((e) => !e.isLate).toList();

  DashboardStats get stats => DashboardStats(
    checkedIn: checkedIn.length,
    checkedOut: checkedOut.length,
    late: late.length,
    onTime: onTime.length,
  );
}
