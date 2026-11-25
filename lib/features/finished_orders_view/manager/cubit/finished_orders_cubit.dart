import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/finished_orders_view/manager/cubit/finished_orders_state.dart';
import 'package:el_karma_ph/features/finished_orders_view/repos/finished_orders_repo.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinishedOrdersCubit extends Cubit<FinishedOrdersState> {
  FinishedOrdersCubit({FinishedOrdersRepo? repo})
    : _repo = repo ?? FinishedOrdersRepo(),
      super(const FinishedOrdersState(status: FinishedOrdersStatus.ready));

  final FinishedOrdersRepo _repo;

  Future<void> loadPeriod(NotesPeriod period) async {
    emit(
      state.copyWith(
        status: FinishedOrdersStatus.loading,
        period: period,
        orders: const [],
      ),
    );
    await _load(period);
  }

  /// للـ pull-to-refresh: بيعيد تحميل نفس الفترة من غير spinner.
  Future<void> refresh() async {
    final period = state.period;
    if (period == null) return;
    await _load(period);
  }

  Future<void> _load(NotesPeriod period) async {
    try {
      final orders = await _repo.getOrders(period.from, period.to);
      if (isClosed || state.period != period) return;
      emit(
        state.copyWith(status: FinishedOrdersStatus.success, orders: orders),
      );
    } on FirebaseException catch (e) {
      log('Failed to load finished orders: ${e.code}');
      if (isClosed || state.period != period) return;
      emit(
        state.copyWith(
          status: FinishedOrdersStatus.failure,
          message: e.code == 'unavailable'
              ? 'error.no_internet'
              : 'orders.load_finished_failed',
        ),
      );
    } catch (e) {
      log('Unexpected error loading finished orders: $e');
      if (isClosed || state.period != period) return;
      emit(
        state.copyWith(
          status: FinishedOrdersStatus.failure,
          message: 'orders.load_finished_failed',
        ),
      );
    }
  }

  void setFilter(FinishedOrdersFilter filter) =>
      emit(state.copyWith(filter: filter));
}
