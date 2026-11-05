import 'dart:developer' show log;

import 'package:el_karma_ph/features/notes_records_view/manager/cubit/notes_summary_state.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/notes_records_view/repos/notes_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesSummaryCubit extends Cubit<NotesSummaryState> {
  NotesSummaryCubit({NotesRepo? repo})
    : _repo = repo ?? NotesRepo(),
      super(
        const NotesSummaryState(status: NotesSummaryStatus.loadingEmployees),
      );

  final NotesRepo _repo;

  Future<void> loadEmployees() async {
    emit(state.copyWith(status: NotesSummaryStatus.loadingEmployees));
    try {
      final employees = await _repo.getEmployees();
      if (isClosed) return;
      emit(
        state.copyWith(status: NotesSummaryStatus.ready, employees: employees),
      );
    } catch (e) {
      log('Failed to load employees: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotesSummaryStatus.failure,
          message: notesErrorKey(e, 'employees.load_failed'),
        ),
      );
    }
  }

  Future<void> calculate(NotesPeriod period) async {
    emit(
      state.copyWith(status: NotesSummaryStatus.calculating, period: period),
    );
    try {
      final summary = await _repo.getSummary(
        state.employees,
        period.from,
        period.to,
      );
      if (isClosed || state.period != period) return;
      emit(
        state.copyWith(status: NotesSummaryStatus.success, summary: summary),
      );
    } catch (e) {
      log('Failed to calculate summary: $e');
      if (isClosed || state.period != period) return;
      emit(
        state.copyWith(
          status: NotesSummaryStatus.failure,
          message: notesErrorKey(e, 'notes.load_failed'),
        ),
      );
    }
  }
}
