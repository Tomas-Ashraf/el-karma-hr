import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/records_view/manager/cubit/records_state.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';
import 'package:el_karma_ph/features/records_view/repos/saved_records_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecordsCubit extends Cubit<RecordsState> {
  RecordsCubit({SavedRecordsRepo? repo})
    : _repo = repo ?? SavedRecordsRepo(),
      super(const RecordsState(status: RecordsStatus.loadingEmployees));

  final SavedRecordsRepo _repo;

  Future<void> loadEmployees() async {
    emit(state.copyWith(status: RecordsStatus.loadingEmployees));
    try {
      final employees = await _repo.getEmployees();
      if (isClosed) return;
      emit(state.copyWith(status: RecordsStatus.ready, employees: employees));
    } on FirebaseException catch (e) {
      log('Failed to load employees: ${e.code}');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: RecordsStatus.failure,
          message: e.code == 'unavailable'
              ? 'error.no_internet'
              : 'employees.load_failed',
        ),
      );
    } catch (e) {
      log('Unexpected error loading employees: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: RecordsStatus.failure,
          message: 'employees.load_failed',
        ),
      );
    }
  }

  Future<void> selectEmployee(String id) async {
    final employee = state.employees.firstWhere((e) => e.id == id);
    emit(
      state.copyWith(
        status: RecordsStatus.loadingRecords,
        selected: employee,
        records: const [],
      ),
    );
    await _loadRecords(employee);
  }

  Future<void> refresh() async {
    final employee = state.selected;
    if (employee == null) return;
    await _loadRecords(employee);
  }

  Future<void> _loadRecords(RecordsEmployee employee) async {
    try {
      final records = await _repo.getRecords(employee);
      if (isClosed || state.selected?.id != employee.id) return;
      emit(state.copyWith(status: RecordsStatus.success, records: records));
    } on FirebaseException catch (e) {
      log('Failed to load records: ${e.code}');
      if (isClosed || state.selected?.id != employee.id) return;
      emit(
        state.copyWith(
          status: RecordsStatus.failure,
          message: e.code == 'unavailable'
              ? 'error.no_internet'
              : 'records.load_failed',
        ),
      );
    } catch (e) {
      log('Unexpected error loading records: $e');
      if (isClosed || state.selected?.id != employee.id) return;
      emit(
        state.copyWith(
          status: RecordsStatus.failure,
          message: 'records.load_failed',
        ),
      );
    }
  }

  Future<String?> deleteRecord(RecordPreview record) async {
    try {
      await _repo.deleteRecord(record);
      if (!isClosed) {
        emit(
          state.copyWith(
            records: state.records.where((r) => r.id != record.id).toList(),
          ),
        );
      }
      return null;
    } on FirebaseException catch (e) {
      log('Failed to delete record: ${e.code}');
      return e.code == 'unavailable'
          ? 'error.no_internet'
          : 'records.delete_failed';
    } catch (e) {
      log('Unexpected error deleting record: $e');
      return 'records.delete_failed';
    }
  }
}
