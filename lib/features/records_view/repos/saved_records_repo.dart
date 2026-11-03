import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/employees_view/repos/employees_repo.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';

class SavedRecordsRepo {
  SavedRecordsRepo({FirebaseFirestore? firestore, EmployeesRepo? employeesRepo})
    : _db = firestore ?? FirebaseFirestore.instance,
      _employeesRepo = employeesRepo ?? EmployeesRepo();

  final FirebaseFirestore _db;
  final EmployeesRepo _employeesRepo;

  CollectionReference<Map<String, dynamic>> _periods(String employeeId) => _db
      .collection(kRecordsCollection)
      .doc(employeeId)
      .collection(kRecordPeriodsCollection);

  Future<List<RecordsEmployee>> getEmployees() async {
    final employees = await _employeesRepo.getEmployees();
    return [for (final e in employees) RecordsEmployee(id: e.id, name: e.name)];
  }

  Future<List<RecordPreview>> getRecords(RecordsEmployee employee) async {
    final snapshot = await _periods(employee.id)
        .orderBy('from', descending: true)
        .get();

    return [
      for (final doc in snapshot.docs)
        RecordPreview.fromFirestore(employee.id, doc.id, doc.data()),
    ];
  }

  Future<void> deleteRecord(RecordPreview record) =>
      _periods(record.employeeId).doc(record.id).delete();
}
