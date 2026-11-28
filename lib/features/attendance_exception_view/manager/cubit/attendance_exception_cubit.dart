import 'dart:developer' show log;

import 'package:el_karma_ph/features/attendance_exception_view/manager/cubit/attendance_exception_state.dart';
import 'package:el_karma_ph/features/attendance_exception_view/models/attendance_exception_models.dart';
import 'package:el_karma_ph/features/attendance_exception_view/repos/attendance_exception_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceExceptionCubit extends Cubit<AttendanceExceptionState> {
  AttendanceExceptionCubit({AttendanceExceptionRepo? repo})
    : _repo = repo ?? AttendanceExceptionRepo(),
      super(
        const AttendanceExceptionState(
          status: ExceptionsStatus.loadingEmployees,
        ),
      );

  final AttendanceExceptionRepo _repo;

  Future<void> loadEmployees() async {
    emit(state.copyWith(status: ExceptionsStatus.loadingEmployees));
    try {
      final employees = await _repo.getEmployees();
      if (isClosed) return;
      emit(
        state.copyWith(status: ExceptionsStatus.ready, employees: employees),
      );
    } catch (e) {
      log('Failed to load employees: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ExceptionsStatus.failure,
          message: exceptionsErrorKey(e, 'employees.load_failed'),
        ),
      );
    }
  }

  Future<void> applyFilter(ExceptionsFilter filter) async {
    emit(
      state.copyWith(
        status: ExceptionsStatus.loading,
        filter: filter,
        items: const [],
      ),
    );
    await _load(filter);
  }

  Future<void> _load(ExceptionsFilter filter) async {
    try {
      final items = await _repo.getExceptions(
        filter.employee.id,
        filter.from,
        filter.to,
      );
      if (isClosed || state.filter != filter) return;
      emit(state.copyWith(status: ExceptionsStatus.success, items: items));
    } catch (e) {
      log('Failed to load exceptions: $e');
      if (isClosed || state.filter != filter) return;
      emit(
        state.copyWith(
          status: ExceptionsStatus.failure,
          message: exceptionsErrorKey(e, 'exceptions.load_failed'),
        ),
      );
    }
  }

  Future<String?> add(AttendanceException item) async {
    final filter = state.filter;
    if (filter == null) return 'error.generic';
    try {
      await _repo.add(filter.employee, item);
      await _load(filter);
      return null;
    } catch (e) {
      log('Failed to add exception: $e');
      return exceptionsErrorKey(e, 'exceptions.save_failed');
    }
  }

  Future<String?> update(AttendanceException item) async {
    final filter = state.filter;
    if (filter == null) return 'error.generic';
    try {
      await _repo.update(filter.employee.id, item);
      await _load(filter);
      return null;
    } catch (e) {
      log('Failed to update exception: $e');
      return exceptionsErrorKey(e, 'exceptions.save_failed');
    }
  }

  Future<String?> delete(AttendanceException item) async {
    final filter = state.filter;
    if (filter == null) return 'error.generic';
    try {
      await _repo.delete(filter.employee.id, item.id);
      if (!isClosed) {
        emit(
          state.copyWith(
            items: state.items.where((i) => i.id != item.id).toList(),
          ),
        );
      }
      return null;
    } catch (e) {
      log('Failed to delete exception: $e');
      return exceptionsErrorKey(e, 'exceptions.delete_failed');
    }
  }
}
