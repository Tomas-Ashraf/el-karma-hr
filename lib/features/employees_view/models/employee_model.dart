import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/add_employee_view/models/add_employee_model.dart';

class EmployeeModel {
  static const maxShifts = 3;

  final String id;
  final String name;
  final String email;
  final String job;
  final String userType;
  final String phoneNumber;
  final double salary;
  final String paymentMethod;
  final String userStatus;
  final int deviceId;
  final String dayOff;
  final List<ShiftRange> shifts;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.job,
    required this.userType,
    required this.phoneNumber,
    required this.salary,
    required this.paymentMethod,
    required this.userStatus,
    required this.deviceId,
    required this.shifts,
    this.dayOff = '',
  });

  bool get isActive => userStatus.trim().toLowerCase() != 'inactive';

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts[0][0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return '$first$second'.toUpperCase();
  }

  factory EmployeeModel.fromDocument(String id, Map<String, dynamic> data) {
    final shifts = <ShiftRange>[];
    for (var n = 1; n <= maxShifts; n++) {
      final start = data['shift${n}_start'];
      final end = data['shift${n}_end'];
      if (start is Timestamp && end is Timestamp) {
        shifts.add(ShiftRange(start: start.toDate(), end: end.toDate()));
      }
    }

    return EmployeeModel(
      id: id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      job: (data['job'] as String?) ?? '',
      userType: (data['user_type'] as String?) ?? '',
      phoneNumber: (data['phone_number'] as String?) ?? '',
      salary: _toDouble(data['salary']),
      paymentMethod: (data['payment_method'] as String?) ?? '',
      userStatus: (data['status'] as String?) ?? '',
      deviceId: _toInt(data['device_id']),
      dayOff: (data['day_off'] as String?) ?? '',
      shifts: shifts,
    );
  }

  EmployeeModel copyWith({List<ShiftRange>? shifts}) {
    return EmployeeModel(
      id: id,
      name: name,
      email: email,
      job: job,
      userType: userType,
      phoneNumber: phoneNumber,
      salary: salary,
      paymentMethod: paymentMethod,
      userStatus: userStatus,
      deviceId: deviceId,
      dayOff: dayOff,
      shifts: shifts ?? this.shifts,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'job': job,
      'user_type': userType,
      'phone_number': phoneNumber,
      'salary': salary,
      'payment_method': paymentMethod,
      'status': userStatus,
      'device_id': deviceId,
      'day_off': dayOff,
    };
    for (var i = 0; i < shifts.length; i++) {
      final n = i + 1;
      map['shift${n}_start'] = Timestamp.fromDate(shifts[i].start);
      map['shift${n}_end'] = Timestamp.fromDate(shifts[i].end);
    }
    return map;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
