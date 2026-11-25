import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/finished_orders_view/models/finished_order.dart';

class FinishedOrdersRepo {
  FinishedOrdersRepo({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<List<FinishedOrder>> getOrders(DateTime from, DateTime to) async {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day + 1);

    final snapshot = await _db
        .collection(kFinishedOrdersCollection)
        .where('finished_at', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('finished_at', isLessThan: Timestamp.fromDate(end))
        .orderBy('finished_at', descending: true)
        .get();

    return [
      for (final doc in snapshot.docs)
        FinishedOrder.fromDocument(doc.id, doc.data()),
    ];
  }
}
