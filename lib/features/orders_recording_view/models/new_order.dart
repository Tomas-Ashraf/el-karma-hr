import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/orders_recording_view/models/delivery_man.dart';

class NewOrder {
  const NewOrder({
    required this.deliveryMan,
    required this.reference,
    required this.amount,
  });

  final DeliveryMan deliveryMan;

  final String reference;

  final double amount;

  Map<String, dynamic> toMap({String? createdBy, String? createdByName}) => {
    'delivery_man_id': deliveryMan.id,
    'delivery_man_name': deliveryMan.name,
    'reference': reference.trim(),
    'amount': amount,
    'status': kOrderStatusPending,
    'created_at': FieldValue.serverTimestamp(),
    'created_by': createdBy,
    'created_by_name': createdByName,
  };
}
