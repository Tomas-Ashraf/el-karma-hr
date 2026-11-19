import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/employees_view/repos/employees_repo.dart';
import 'package:el_karma_ph/features/orders_recording_view/models/delivery_man.dart';
import 'package:el_karma_ph/features/orders_recording_view/models/new_order.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersRepo {
  OrdersRepo({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    EmployeesRepo? employeesRepo,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _employeesRepo = employeesRepo ?? EmployeesRepo();

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final EmployeesRepo _employeesRepo;

  Future<List<DeliveryMan>> getDeliveryMen() async {
    final employees = await _employeesRepo.getEmployees();
    return [
      for (final e in employees)
        if (e.isActive && e.job.trim().toLowerCase() == kDeliveryJob)
          DeliveryMan(id: e.id, name: e.name),
    ];
  }

  Future<void> addOrder(NewOrder order) async {
    final prefs = await SharedPreferences.getInstance();
    final cashierName = prefs.getString('userName');

    await _db
        .collection(kCurrentOrdersCollection)
        .add(
          order.toMap(
            createdBy: _auth.currentUser?.uid,
            createdByName: (cashierName == null || cashierName.isEmpty)
                ? null
                : cashierName,
          ),
        );
  }
}
