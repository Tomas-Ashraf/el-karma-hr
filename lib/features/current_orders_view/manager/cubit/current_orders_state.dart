import 'package:el_karma_ph/features/current_orders_view/models/order_item.dart';

enum CurrentOrdersStatus { loading, success, failure }

class CurrentOrdersState {
  const CurrentOrdersState({
    required this.status,
    this.orders = const [],
    this.message,
  });

  final CurrentOrdersStatus status;
  final List<OrderItem> orders;
  final String? message;

  CurrentOrdersState copyWith({
    CurrentOrdersStatus? status,
    List<OrderItem>? orders,
    String? message,
  }) => CurrentOrdersState(
    status: status ?? this.status,
    orders: orders ?? this.orders,
    message: message,
  );
}
