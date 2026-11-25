import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, success, failed }

class OrderItem {
  const OrderItem({
    required this.id,
    required this.reference,
    required this.deliveryMan,
    required this.amount,
    required this.createdAt,
    this.status = OrderStatus.pending,
  });

  final String id;
  final String reference;
  final String deliveryMan;
  final double amount;
  final DateTime createdAt;
  final OrderStatus status;

  factory OrderItem.fromDocument(String id, Map<String, dynamic> data) {
    final created = data['created_at'];
    return OrderItem(
      id: id,
      reference: (data['reference'] as String?) ?? '',
      deliveryMan: (data['delivery_man_name'] as String?) ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }
}
