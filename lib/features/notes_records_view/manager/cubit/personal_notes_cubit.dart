import 'dart:developer' show log;

import 'package:el_karma_ph/features/notes_records_view/manager/cubit/personal_notes_state.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/notes_records_view/repos/notes_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalNotesCubit extends Cubit<PersonalNotesState> {
  PersonalNotesCubit({NotesRepo? repo})
    : _repo = repo ?? NotesRepo(),
      super(const PersonalNotesState(status: NotesLoadStatus.loading));

  final NotesRepo _repo;

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: NotesLoadStatus.loading));
    try {
      final notes = await _repo.getPersonalNotes();
      if (isClosed) return;
      emit(state.copyWith(status: NotesLoadStatus.success, notes: notes));
    } catch (e) {
      log('Failed to load personal notes: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotesLoadStatus.failure,
          message: notesErrorKey(e, 'notes.load_failed'),
        ),
      );
    }
  }

  Future<String?> save({
    PersonalNote? note,
    required String title,
    required String body,
    required int colorIndex,
  }) async {
    try {
      await _repo.savePersonalNote(
        id: note?.id,
        title: title,
        body: body,
        colorIndex: colorIndex,
      );
      await load(silent: true);
      return null;
    } catch (e) {
      log('Failed to save personal note: $e');
      return notesErrorKey(e, 'notes.save_failed');
    }
  }

  Future<String?> delete(PersonalNote note) async {
    try {
      await _repo.deletePersonalNote(note.id);
      if (!isClosed) {
        emit(
          state.copyWith(
            notes: state.notes.where((n) => n.id != note.id).toList(),
          ),
        );
      }
      return null;
    } catch (e) {
      log('Failed to delete personal note: $e');
      return notesErrorKey(e, 'notes.delete_failed');
    }
  }
}
