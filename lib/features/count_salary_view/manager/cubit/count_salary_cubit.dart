import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/count_salary_view/manager/cubit/count_salary_state.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';
import 'package:el_karma_ph/features/count_salary_view/repos/count_salary_repo.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CountSalaryCubit extends Cubit<CountSalaryState> {
  CountSalaryCubit({CountSalaryRepo? repo})
    : _repo = repo ?? CountSalaryRepo(),
      super(const CountSalaryState(status: CountSalaryStatus.loadingEmployees));

  final CountSalaryRepo _repo;

  String _errorKey(Object e, String fallback) =>
      e is FirebaseException && e.code == 'unavailable'
      ? 'error.no_internet'
      : fallback;

  Future<void> loadEmployees() async {
    emit(state.copyWith(status: CountSalaryStatus.loadingEmployees));
    try {
      final employees = await _repo.getEmployees();
      if (isClosed) return;
      emit(
        state.copyWith(status: CountSalaryStatus.ready, employees: employees),
      );
    } catch (e) {
      log('Failed to load employees: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CountSalaryStatus.failure,
          message: _errorKey(e, 'employees.load_failed'),
        ),
      );
    }
  }

  Future<void> selectEmployee(String id) async {
    final employee = state.employees.firstWhere((e) => e.id == id);
    emit(
      state.copyWith(
        status: CountSalaryStatus.loadingRecords,
        selected: employee,
        records: const [],
        statuses: const {},
      ),
    );
    try {
      final results = await Future.wait<Object>([
        _repo.getRecords(employee),
        _repo.getStatuses(employee),
      ]);
      if (isClosed || state.selected?.id != employee.id) return;
      emit(
        state.copyWith(
          status: CountSalaryStatus.success,
          records: results[0] as List<RecordPreview>,
          statuses: results[1] as Map<String, SalaryStatus>,
        ),
      );
    } catch (e) {
      log('Failed to load records: $e');
      if (isClosed || state.selected?.id != employee.id) return;
      emit(
        state.copyWith(
          status: CountSalaryStatus.failure,
          message: _errorKey(e, 'records.load_failed'),
        ),
      );
    }
  }

  Future<({SalarySheet? sheet, String? error})> calculate(
    RecordPreview record,
  ) async {
    final EmployeeModel? employee = state.selected;
    if (employee == null || state.isCalculating) {
      return (sheet: null, error: null);
    }

    emit(state.copyWith(isCalculating: true));
    try {
      final sheet = await _repo.buildSheet(employee, record);
      return (sheet: sheet, error: null);
    } catch (e) {
      log('Failed to calculate salary: $e');
      return (sheet: null, error: _errorKey(e, 'salary.calc_failed'));
    } finally {
      if (!isClosed) emit(state.copyWith(isCalculating: false));
    }
  }

  Future<void> refreshStatuses() async {
    final employee = state.selected;
    if (employee == null) return;
    try {
      final statuses = await _repo.getStatuses(employee);
      if (isClosed || state.selected?.id != employee.id) return;
      emit(state.copyWith(statuses: statuses));
    } catch (e) {
      log('Failed to refresh statuses: $e');
    }
  }
}
