import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/current_orders_view/manager/cubit/current_orders_state.dart';
import 'package:el_karma_ph/features/current_orders_view/models/order_item.dart';
import 'package:el_karma_ph/features/current_orders_view/repos/current_orders_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentOrdersCubit extends Cubit<CurrentOrdersState> {
  CurrentOrdersCubit({CurrentOrdersRepo? repo})
    : _repo = repo ?? CurrentOrdersRepo(),
      super(const CurrentOrdersState(status: CurrentOrdersStatus.loading));

  final CurrentOrdersRepo _repo;

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: CurrentOrdersStatus.loading));
    try {
      final orders = await _repo.getOrders();
      if (isClosed) return;
      emit(state.copyWith(status: CurrentOrdersStatus.success, orders: orders));
    } on FirebaseException catch (e) {
      log('Failed to load orders: ${e.code}');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CurrentOrdersStatus.failure,
          message: e.code == 'unavailable'
              ? 'error.no_internet'
              : 'orders.load_orders_failed',
        ),
      );
    } catch (e) {
      log('Unexpected error loading orders: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CurrentOrdersStatus.failure,
          message: 'orders.load_orders_failed',
        ),
      );
    }
  }

  Future<String?> markSuccess(OrderItem order, double returnedAmount) =>
      _finish(order, success: true, returnedAmount: returnedAmount);

  Future<String?> markFailed(OrderItem order, String reason) =>
      _finish(order, success: false, failureReason: reason);

  Future<String?> _finish(
    OrderItem order, {
    required bool success,
    double? returnedAmount,
    String? failureReason,
  }) async {
    _setProcessing(order.id, true);
    try {
      await _repo.finishOrder(
        order,
        success: success,
        returnedAmount: returnedAmount,
        failureReason: failureReason,
      );
      _remove(order);
      return null;
    } on OrderAlreadyProcessedException {
      _remove(order);
      return 'orders.already_processed';
    } on FirebaseException catch (e) {
      log('Failed to finish order: ${e.code}');
      return e.code == 'unavailable'
          ? 'error.no_internet'
          : 'orders.complete_failed';
    } catch (e) {
      log('Unexpected error finishing order: $e');
      return 'orders.complete_failed';
    } finally {
      _setProcessing(order.id, false);
    }
  }

  void _setProcessing(String id, bool busy) {
    if (isClosed) return;
    final ids = {...state.processingIds};
    busy ? ids.add(id) : ids.remove(id);
    emit(state.copyWith(processingIds: ids));
  }

  void _remove(OrderItem order) {
    if (isClosed) return;
    emit(
      state.copyWith(
        orders: state.orders.where((o) => o.id != order.id).toList(),
      ),
    );
  }
}
