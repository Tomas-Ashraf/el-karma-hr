import 'dart:developer' show log;

import 'package:el_karma_ph/features/notes_records_view/manager/cubit/employee_adjustments_state.dart';
import 'package:el_karma_ph/features/notes_records_view/manager/cubit/personal_notes_state.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/notes_records_view/repos/notes_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeAdjustmentsCubit extends Cubit<EmployeeAdjustmentsState> {
  EmployeeAdjustmentsCubit(this.args, {NotesRepo? repo})
    : _repo = repo ?? NotesRepo(),
      super(const EmployeeAdjustmentsState(status: NotesLoadStatus.loading));

  final NotesEmployeeArgs args;
  final NotesRepo _repo;

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: NotesLoadStatus.loading));
    try {
      final items = await _repo.getAdjustments(
        args.employeeId,
        args.from,
        args.to,
      );
      if (isClosed) return;
      emit(state.copyWith(status: NotesLoadStatus.success, items: items));
    } catch (e) {
      log('Failed to load employee adjustments: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotesLoadStatus.failure,
          message: notesErrorKey(e, 'notes.load_failed'),
        ),
      );
    }
  }
}
