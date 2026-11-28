import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:flutter/material.dart' show TimeOfDay;

enum ExceptionType { lateArrival, earlyLeave, dayOff }

extension ExceptionTypeKey on ExceptionType {
  String get key => switch (this) {
    ExceptionType.lateArrival => 'late_arrival',
    ExceptionType.earlyLeave => 'early_leave',
    ExceptionType.dayOff => 'day_off',
  };
}

ExceptionType exceptionTypeFromKey(String? key) => switch (key) {
  'early_leave' => ExceptionType.earlyLeave,
  'day_off' => ExceptionType.dayOff,
  _ => ExceptionType.lateArrival,
};

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

  final DateTime date;

  final TimeOfDay? time;
  final String reason;

  factory AttendanceException.fromDocument(
    String id,
    Map<String, dynamic> data,
  ) {
    final ts = data['date'];
    final minutes = (data['time_minutes'] as num?)?.toInt();
    return AttendanceException(
      id: id,
      employeeId: (data['employee_id'] as String?) ?? '',
      type: exceptionTypeFromKey(data['type'] as String?),
      date: ts is Timestamp
          ? ts.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      time: minutes == null
          ? null
          : TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      reason: (data['reason'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    final t = time;
    return {
      'type': type.key,
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'time_minutes': t == null ? null : t.hour * 60 + t.minute,
      'reason': reason,
    };
  }
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
