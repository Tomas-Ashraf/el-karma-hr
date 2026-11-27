import 'package:el_karma_ph/features/attendance_exception_view/models/attendance_exception_models.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:flutter/material.dart' show TimeOfDay;

EmployeeModel _emp(String id, String name, String job, int device) {
  return EmployeeModel(
    id: id,
    name: name,
    email: '$id@example.com',
    job: job,
    userType: 'employee',
    phoneNumber: '01012345678',
    salary: 6000,
    paymentMethod: 'cash',
    userStatus: 'active',
    deviceId: device,
    shifts: const [],
  );
}

/// موظفين وهميين لحد ما نربط الداتا الحقيقية.
final fakeEmployees = <EmployeeModel>[
  _emp('e1', 'Mina Samy', 'doctor', 1),
  _emp('e2', 'Sara Adel', 'cashier', 2),
  _emp('e3', 'Ahmed Hany', 'delivery', 3),
];

List<AttendanceException> buildFakeExceptions() {
  final now = DateTime.now();
  DateTime day(int back) => DateTime(now.year, now.month, now.day - back);

  return [
    AttendanceException(
      id: 'x1',
      employeeId: 'e1',
      type: ExceptionType.lateArrival,
      date: day(0),
      time: const TimeOfDay(hour: 11, minute: 0),
      reason: 'Doctor appointment',
    ),
    AttendanceException(
      id: 'x2',
      employeeId: 'e1',
      type: ExceptionType.earlyLeave,
      date: day(2),
      time: const TimeOfDay(hour: 17, minute: 30),
      reason: 'Family matter',
    ),
    AttendanceException(
      id: 'x3',
      employeeId: 'e1',
      type: ExceptionType.dayOff,
      date: day(5),
      reason: 'Sick leave',
    ),
    AttendanceException(
      id: 'x4',
      employeeId: 'e2',
      type: ExceptionType.lateArrival,
      date: day(1),
      time: const TimeOfDay(hour: 10, minute: 30),
    ),
    AttendanceException(
      id: 'x5',
      employeeId: 'e3',
      type: ExceptionType.dayOff,
      date: day(3),
      reason: 'Personal',
    ),
  ];
}
