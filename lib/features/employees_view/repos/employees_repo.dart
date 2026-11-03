import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/add_employee_view/models/add_employee_model.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';

class EmployeeEmailExistsException implements Exception {
  const EmployeeEmailExistsException();
}

class DeviceIdExistsException implements Exception {
  const DeviceIdExistsException();
}

class EmployeesRepo {
  EmployeesRepo({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(kUsersCollection);

  Future<List<EmployeeModel>> getEmployees() async {
    final snapshot = await _users.get();

    final employees = snapshot.docs
        .map((doc) => EmployeeModel.fromDocument(doc.id, doc.data()))
        .toList();

    employees.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return employees;
  }

  Future<void> addEmployee(NewEmployee employee) async {
    final emailQuery = await _users
        .where('email', isEqualTo: employee.normalizedEmail)
        .limit(1)
        .get();
    if (emailQuery.docs.isNotEmpty) throw const EmployeeEmailExistsException();

    final deviceQuery = await _users
        .where('device_id', isEqualTo: employee.deviceId)
        .limit(1)
        .get();
    if (deviceQuery.docs.isNotEmpty) throw const DeviceIdExistsException();

    await _users.add(employee.toMap());
  }

  Future<void> updateEmployee(String id, Map<String, dynamic> data) async {
    final newDeviceId = data['device_id'];
    if (newDeviceId != null) {
      final query = await _users
          .where('device_id', isEqualTo: newDeviceId)
          .limit(2)
          .get();
      if (query.docs.any((doc) => doc.id != id)) {
        throw const DeviceIdExistsException();
      }
    }
    await _users.doc(id).update(data);
  }

  Future<void> deleteEmployee(String id) => _users.doc(id).delete();
  Future<EmployeeModel?> getEmployee(String id) async {
    final doc = await _users.doc(id).get();
    final data = doc.data();
    if (data == null) return null;
    return EmployeeModel.fromDocument(doc.id, data);
  }
}
