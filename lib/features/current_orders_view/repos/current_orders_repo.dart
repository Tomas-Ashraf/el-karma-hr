import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/current_orders_view/models/order_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderAlreadyProcessedException implements Exception {
  const OrderAlreadyProcessedException();
}

class CurrentOrdersRepo {
  CurrentOrdersRepo({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Future<List<OrderItem>> getOrders() async {
    final snapshot = await _db
        .collection(kCurrentOrdersCollection)
        .orderBy('created_at', descending: true)
        .get();
    return [
      for (final doc in snapshot.docs)
        OrderItem.fromDocument(doc.id, doc.data()),
    ];
  }

  Future<void> finishOrder(
    OrderItem order, {
    required bool success,
    double? returnedAmount,
    String? failureReason,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cashier = prefs.getString('userName');

    final currentRef = _db.collection(kCurrentOrdersCollection).doc(order.id);
    final finishedRef = _db.collection(kFinishedOrdersCollection).doc(order.id);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(currentRef);
      final data = snap.data();
      if (data == null) throw const OrderAlreadyProcessedException();

      tx.set(finishedRef, {
        ...data,
        'status': success ? kOrderStatusSuccess : kOrderStatusFailed,
        if (success) ...{
          'returned_amount': returnedAmount,
          'amount_matched':
              returnedAmount != null &&
              (returnedAmount - order.amount).abs() < 0.005,
        } else
          'failure_reason': (failureReason ?? '').trim(),
        'finished_at': FieldValue.serverTimestamp(),
        'finished_by': _auth.currentUser?.uid,
        'finished_by_name': (cashier == null || cashier.isEmpty)
            ? null
            : cashier,
      });
      tx.delete(currentRef);
    });
  }
}
