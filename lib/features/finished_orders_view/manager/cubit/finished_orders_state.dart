import 'package:el_karma_ph/features/finished_orders_view/models/finished_order.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';

enum FinishedOrdersStatus { ready, loading, success, failure }

enum FinishedOrdersFilter { all, success, failed }

class FinishedOrdersState {
  const FinishedOrdersState({
    required this.status,
    this.orders = const [],
    this.period,
    this.filter = FinishedOrdersFilter.all,
    this.message,
  });

  final FinishedOrdersStatus status;
  final List<FinishedOrder> orders;
  final NotesPeriod? period;
  final FinishedOrdersFilter filter;
  final String? message;

  List<FinishedOrder> get visible => switch (filter) {
    FinishedOrdersFilter.all => orders,
    FinishedOrdersFilter.success => [
      for (final o in orders)
        if (o.isSuccess) o,
    ],
    FinishedOrdersFilter.failed => [
      for (final o in orders)
        if (!o.isSuccess) o,
    ],
  };

  FinishedOrdersState copyWith({
    FinishedOrdersStatus? status,
    List<FinishedOrder>? orders,
    NotesPeriod? period,
    FinishedOrdersFilter? filter,
    String? message,
  }) => FinishedOrdersState(
    status: status ?? this.status,
    orders: orders ?? this.orders,
    period: period ?? this.period,
    filter: filter ?? this.filter,
    message: message,
  );
}
