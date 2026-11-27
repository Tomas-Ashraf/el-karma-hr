import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/count_salary_view/models/saved_salary_sheet.dart';
import 'package:el_karma_ph/features/count_salary_view/repos/salary_sheets_repo.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SalaryHistoryStatus { loading, success, failure }

class SalaryHistoryState {
  const SalaryHistoryState({
    required this.status,
    this.items = const [],
    this.message,
  });

  final SalaryHistoryStatus status;
  final List<SavedSalarySheet> items;
  final String? message;
}

class SalaryHistoryCubit extends Cubit<SalaryHistoryState> {
  SalaryHistoryCubit(this.employee, {SalarySheetsRepo? repo})
    : _repo = repo ?? SalarySheetsRepo(),
      super(const SalaryHistoryState(status: SalaryHistoryStatus.loading));

  final EmployeeModel employee;
  final SalarySheetsRepo _repo;

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(const SalaryHistoryState(status: SalaryHistoryStatus.loading));
    }
    try {
      final items = await _repo.getHistory(employee.id);
      if (isClosed) return;
      emit(
        SalaryHistoryState(status: SalaryHistoryStatus.success, items: items),
      );
    } catch (e) {
      log('Failed to load salary history: $e');
      if (isClosed) return;
      emit(
        SalaryHistoryState(
          status: SalaryHistoryStatus.failure,
          message: e is FirebaseException && e.code == 'unavailable'
              ? 'error.no_internet'
              : 'salary.history_load_failed',
        ),
      );
    }
  }
}
