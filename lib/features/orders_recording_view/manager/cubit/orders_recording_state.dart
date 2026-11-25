import 'package:el_karma_ph/features/orders_recording_view/models/delivery_man.dart';

enum OrdersRecordingStatus { loading, ready, failure }

enum OrderSubmitStatus { idle, saving, saved, failed }

class OrdersRecordingState {
  const OrdersRecordingState({
    required this.status,
    this.deliveryMen = const [],
    this.submitStatus = OrderSubmitStatus.idle,
    this.message,
  });

  final OrdersRecordingStatus status;
  final List<DeliveryMan> deliveryMen;
  final OrderSubmitStatus submitStatus;
  final String? message;

  OrdersRecordingState copyWith({
    OrdersRecordingStatus? status,
    List<DeliveryMan>? deliveryMen,
    OrderSubmitStatus? submitStatus,
    String? message,
  }) {
    return OrdersRecordingState(
      status: status ?? this.status,
      deliveryMen: deliveryMen ?? this.deliveryMen,
      submitStatus: submitStatus ?? this.submitStatus,
      message: message,
    );
  }
}
