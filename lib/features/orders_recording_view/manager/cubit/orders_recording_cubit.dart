import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/orders_recording_view/manager/cubit/orders_recording_state.dart';
import 'package:el_karma_ph/features/orders_recording_view/models/new_order.dart';
import 'package:el_karma_ph/features/orders_recording_view/repos/orders_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersRecordingCubit extends Cubit<OrdersRecordingState> {
  OrdersRecordingCubit({OrdersRepo? repo})
    : _repo = repo ?? OrdersRepo(),
      super(const OrdersRecordingState(status: OrdersRecordingStatus.loading));

  final OrdersRepo _repo;

  Future<void> loadDeliveryMen() async {
    emit(state.copyWith(status: OrdersRecordingStatus.loading));
    try {
      final deliveryMen = await _repo.getDeliveryMen();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrdersRecordingStatus.ready,
          deliveryMen: deliveryMen,
        ),
      );
    } on FirebaseException catch (e) {
      log('Failed to load delivery men: ${e.code}');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrdersRecordingStatus.failure,
          message: e.code == 'unavailable'
              ? 'error.no_internet'
              : 'orders.load_failed',
        ),
      );
    } catch (e) {
      log('Unexpected error loading delivery men: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OrdersRecordingStatus.failure,
          message: 'orders.load_failed',
        ),
      );
    }
  }

  Future<void> addOrder(NewOrder order) async {
    if (state.submitStatus == OrderSubmitStatus.saving) return;
    emit(state.copyWith(submitStatus: OrderSubmitStatus.saving));

    try {
      await _repo.addOrder(order);
      if (isClosed) return;
      emit(state.copyWith(submitStatus: OrderSubmitStatus.saved));
    } on FirebaseException catch (e) {
      log('Failed to add order: ${e.code}');
      if (isClosed) return;
      emit(
        state.copyWith(
          submitStatus: OrderSubmitStatus.failed,
          message: e.code == 'unavailable'
              ? 'error.no_internet'
              : 'orders.add_failed',
        ),
      );
    } catch (e) {
      log('Unexpected error adding order: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          submitStatus: OrderSubmitStatus.failed,
          message: 'orders.add_failed',
        ),
      );
    }
  }
}
