import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
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
  final Timestamp shift1Start;
  final Timestamp shift1End;

  EmployeeModel({
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
    required this.shift1Start,
    required this.shift1End,
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
      shift1Start: _toTimestamp(data['shift1_start']),
      shift1End: _toTimestamp(data['shift1_end']),
    );
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

  static Timestamp _toTimestamp(dynamic value) {
    if (value is Timestamp) return value;
    return Timestamp.fromMillisecondsSinceEpoch(0);
  }
}
