import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';

class FinishedOrder {
  const FinishedOrder({
    required this.id,
    required this.reference,
    required this.deliveryMan,
    required this.amount,
    required this.isSuccess,
    required this.createdAt,
    required this.finishedAt,
    this.returnedAmount,
    this.amountMatched,
    this.failureReason = '',
    this.finishedByName,
  });

  final String id;
  final String reference;
  final String deliveryMan;
  final double amount;
  final bool isSuccess;
  final DateTime? createdAt;
  final DateTime? finishedAt;
  final double? returnedAmount;
  final bool? amountMatched;
  final String failureReason;
  final String? finishedByName;

  factory FinishedOrder.fromDocument(String id, Map<String, dynamic> data) {
    DateTime? date(dynamic v) => v is Timestamp ? v.toDate() : null;

    return FinishedOrder(
      id: id,
      reference: (data['reference'] as String?) ?? '',
      deliveryMan: (data['delivery_man_name'] as String?) ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      isSuccess: data['status'] == kOrderStatusSuccess,
      createdAt: date(data['created_at']),
      finishedAt: date(data['finished_at']),
      returnedAmount: (data['returned_amount'] as num?)?.toDouble(),
      amountMatched: data['amount_matched'] as bool?,
      failureReason: (data['failure_reason'] as String?) ?? '',
      finishedByName: data['finished_by_name'] as String?,
    );
  }
}
