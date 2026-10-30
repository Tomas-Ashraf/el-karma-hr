import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/attendance_view.dart/models/attendance_record.dart';

class RecordsRepo {
  RecordsRepo({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<void> saveRecord(AttendanceRecord record) async {
    final employeeRef = _db
        .collection(kRecordsCollection)
        .doc(record.employee.id);
    final periodRef = employeeRef
        .collection(kRecordPeriodsCollection)
        .doc(record.periodId);

    final batch = _db.batch();
    batch.set(employeeRef, record.employeeMap(), SetOptions(merge: true));
    batch.set(periodRef, record.toMap());
    await batch.commit();
  }
}
