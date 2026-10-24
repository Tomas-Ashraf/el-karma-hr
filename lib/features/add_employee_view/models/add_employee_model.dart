import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftRange {
  const ShiftRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

class NewEmployee {
  const NewEmployee({
    required this.name,
    required this.email,
    required this.job,
    required this.userType,
    required this.phoneNumber,
    required this.salary,
    required this.paymentMethod,
    required this.status,
    required this.deviceId,
    required this.shifts,
  });

  final String name;
  final String email;
  final String job;
  final String userType;
  final String phoneNumber;
  final double salary;
  final String paymentMethod;
  final String status;
  final int deviceId;
  final List<ShiftRange> shifts;

  String get normalizedEmail => email.trim().toLowerCase();

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name.trim(),
      'email': normalizedEmail,
      'job': job.trim(),
      'user_type': userType,
      'phone_number': phoneNumber.trim(),
      'salary': salary,
      'payment_method': paymentMethod,
      'status': status,
      'device_id': deviceId,
      'created_at': FieldValue.serverTimestamp(),
    };

    for (var i = 0; i < shifts.length; i++) {
      final n = i + 1;
      map['shift${n}_start'] = Timestamp.fromDate(shifts[i].start);
      map['shift${n}_end'] = Timestamp.fromDate(shifts[i].end);
    }
    return map;
  }
}
