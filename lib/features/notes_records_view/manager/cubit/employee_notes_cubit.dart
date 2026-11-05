import 'dart:developer' show log;

import 'package:el_karma_ph/features/notes_records_view/manager/cubit/employee_notes_state.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/notes_records_view/repos/notes_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeNotesCubit extends Cubit<EmployeeNotesState> {
  EmployeeNotesCubit({NotesRepo? repo})
    : _repo = repo ?? NotesRepo(),
      super(
        const EmployeeNotesState(status: EmployeeNotesStatus.loadingEmployees),
      );

  final NotesRepo _repo;

  Future<void> loadEmployees() async {
    emit(state.copyWith(status: EmployeeNotesStatus.loadingEmployees));
    try {
      final employees = await _repo.getEmployees();
      if (isClosed) return;
      emit(
        state.copyWith(status: EmployeeNotesStatus.ready, employees: employees),
      );
    } catch (e) {
      log('Failed to load employees: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: EmployeeNotesStatus.failure,
          message: notesErrorKey(e, 'employees.load_failed'),
        ),
      );
    }
  }

  Future<void> applyFilter(NotesFilter filter) async {
    emit(
      state.copyWith(
        status: EmployeeNotesStatus.loading,
        filter: filter,
        items: const [],
      ),
    );
    await _load(filter);
  }

  Future<void> _load(NotesFilter filter) async {
    try {
      final items = await _repo.getAdjustments(
        filter.employee.id,
        filter.from,
        filter.to,
      );
      if (isClosed || state.filter != filter) return;
      emit(state.copyWith(status: EmployeeNotesStatus.success, items: items));
    } catch (e) {
      log('Failed to load adjustments: $e');
      if (isClosed || state.filter != filter) return;
      emit(
        state.copyWith(
          status: EmployeeNotesStatus.failure,
          message: notesErrorKey(e, 'notes.load_failed'),
        ),
      );
    }
  }

  Future<String?> addAdjustment(AdjustmentDraft draft) async {
    try {
      await _repo.addAdjustment(draft);
      final filter = state.filter;
      if (filter != null) await _load(filter);
      return null;
    } catch (e) {
      log('Failed to add adjustment: $e');
      return notesErrorKey(e, 'notes.save_failed');
    }
  }

  Future<String?> deleteAdjustment(EmployeeAdjustment item) async {
    try {
      await _repo.deleteAdjustment(item);
      if (!isClosed) {
        emit(
          state.copyWith(
            items: state.items.where((i) => i.id != item.id).toList(),
          ),
        );
      }
      return null;
    } catch (e) {
      log('Failed to delete adjustment: $e');
      return notesErrorKey(e, 'notes.delete_failed');
    }
  }
}
