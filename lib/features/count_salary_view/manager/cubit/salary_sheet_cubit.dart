import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_breakdown.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';
import 'package:el_karma_ph/features/count_salary_view/repos/salary_sheets_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalarySheetState {
  const SalarySheetState({required this.sheet, this.saving = false});

  final SalarySheet sheet;
  final bool saving;
}

class SalarySheetCubit extends Cubit<SalarySheetState> {
  SalarySheetCubit(SalarySheet sheet, {SalarySheetsRepo? repo})
    : _repo = repo ?? SalarySheetsRepo(),
      super(SalarySheetState(sheet: sheet));

  final SalarySheetsRepo _repo;

  String _errorKey(Object e) =>
      e is FirebaseException && e.code == 'unavailable'
      ? 'error.no_internet'
      : 'salary.save_failed';

  Future<void> init() async {
    final sheet = state.sheet;
    if (sheet.isPaid) return;
    try {
      await _repo.save(
        sheet,
        status: SalaryStatus.calculated,
        first: sheet.status == SalaryStatus.notCalculated,
      );
      if (isClosed) return;
      emit(
        SalarySheetState(
          sheet: state.sheet.copyWith(status: SalaryStatus.calculated),
        ),
      );
    } catch (e) {
      log('Failed to save salary sheet: $e');
    }
  }

  SalarySheet _apply(SalarySheet s, SalaryField f, double v) => switch (f) {
    SalaryField.baseSalary => s.copyWith(baseSalary: v),
    SalaryField.absentDays => s.copyWith(absentDays: v),
    SalaryField.lateDeduction => s.copyWith(lateDeduction: v),
    SalaryField.deliveryOrders => s.copyWith(deliveryOrders: v.round()),
    SalaryField.bonus => s.copyWith(bonusOverride: v),
    SalaryField.deduction => s.copyWith(deductionOverride: v),
  };

  Future<String?> edit(SalaryField field, double value) async {
    final old = state.sheet;
    if (old.isPaid) return null;

    final updated = _apply(old, field, value).copyWith(
      status: SalaryStatus.calculated,
      editedFields: {...old.editedFields, field.name},
    );
    emit(SalarySheetState(sheet: updated, saving: true));
    try {
      await _repo.save(
        updated,
        status: SalaryStatus.calculated,
        first: old.status == SalaryStatus.notCalculated,
      );
      if (!isClosed) emit(SalarySheetState(sheet: state.sheet));
      return null;
    } catch (e) {
      log('Failed to save edit: $e');
      if (!isClosed) emit(SalarySheetState(sheet: state.sheet));
      return _errorKey(e);
    }
  }

  Future<String?> markPaid() async {
    final sheet = state.sheet;
    if (sheet.isPaid || state.saving) return null;

    emit(SalarySheetState(sheet: sheet, saving: true));
    try {
      await _repo.save(
        sheet,
        status: SalaryStatus.paid,
        first: sheet.status == SalaryStatus.notCalculated,
      );
      if (!isClosed) {
        emit(
          SalarySheetState(sheet: sheet.copyWith(status: SalaryStatus.paid)),
        );
      }
      return null;
    } catch (e) {
      log('Failed to mark paid: $e');
      if (!isClosed) emit(SalarySheetState(sheet: sheet));
      return _errorKey(e);
    }
  }
}
