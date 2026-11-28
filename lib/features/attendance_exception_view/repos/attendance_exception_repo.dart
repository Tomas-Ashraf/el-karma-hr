import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/attendance_exception_view/models/attendance_exception_models.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/employees_view/repos/employees_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceExceptionRepo {
  AttendanceExceptionRepo({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    EmployeesRepo? employeesRepo,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _employeesRepo = employeesRepo ?? EmployeesRepo();

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final EmployeesRepo _employeesRepo;

  DocumentReference<Map<String, dynamic>> _root(String employeeId) =>
      _db.collection(kExceptionsCollection).doc(employeeId);

  CollectionReference<Map<String, dynamic>> _items(String employeeId) =>
      _root(employeeId).collection(kExceptionItemsCollection);

  Future<List<EmployeeModel>> getEmployees() => _employeesRepo.getEmployees();

  Future<List<AttendanceException>> getExceptions(
    String employeeId,
    DateTime from,
    DateTime to,
  ) async {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day + 1);

    final snapshot = await _items(employeeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();

    return [
      for (final doc in snapshot.docs)
        AttendanceException.fromDocument(doc.id, doc.data()),
    ];
  }

  Future<void> add(EmployeeModel employee, AttendanceException item) async {
    final ref = _items(employee.id).doc();

    final batch = _db.batch();
    batch.set(_root(employee.id), {
      'employee_name': employee.name,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(ref, {
      ...item.toMap(),
      'employee_id': employee.id,
      'employee_name': employee.name,
      'created_by': _auth.currentUser?.uid,
      'created_at': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> update(String employeeId, AttendanceException item) {
    return _items(employeeId)
        .doc(item.id)
        .update({...item.toMap(), 'updated_at': FieldValue.serverTimestamp()});
  }

  Future<void> delete(String employeeId, String id) =>
      _items(employeeId).doc(id).delete();
}

String exceptionsErrorKey(Object error, String fallback) =>
    error is FirebaseException && error.code == 'unavailable'
    ? 'error.no_internet'
    : fallback;
