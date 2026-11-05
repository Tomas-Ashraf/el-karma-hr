import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';

enum NotesLoadStatus { loading, success, failure }

class PersonalNotesState {
  const PersonalNotesState({
    required this.status,
    this.notes = const [],
    this.message,
  });

  final NotesLoadStatus status;
  final List<PersonalNote> notes;
  final String? message;

  PersonalNotesState copyWith({
    NotesLoadStatus? status,
    List<PersonalNote>? notes,
    String? message,
  }) {
    return PersonalNotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      message: message,
    );
  }
}
