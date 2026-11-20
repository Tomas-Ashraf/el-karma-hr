import 'package:el_karma_ph/features/current_orders_view/models/order_item.dart';

enum CurrentOrdersStatus { loading, success, failure }

class CurrentOrdersState {
  const CurrentOrdersState({
    required this.status,
    this.orders = const [],
    this.processingIds = const {},
    this.message,
  });

  final CurrentOrdersStatus status;
  final List<OrderItem> orders;

  final Set<String> processingIds;
  final String? message;

  CurrentOrdersState copyWith({
    CurrentOrdersStatus? status,
    List<OrderItem>? orders,
    Set<String>? processingIds,
    String? message,
  }) => CurrentOrdersState(
    status: status ?? this.status,
    orders: orders ?? this.orders,
    processingIds: processingIds ?? this.processingIds,
    message: message,
  );
}
