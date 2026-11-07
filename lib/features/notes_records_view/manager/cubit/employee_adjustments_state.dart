import 'package:el_karma_ph/features/notes_records_view/manager/cubit/personal_notes_state.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';

class EmployeeAdjustmentsState {
  const EmployeeAdjustmentsState({
    required this.status,
    this.items = const [],
    this.message,
  });

  final NotesLoadStatus status;
  final List<EmployeeAdjustment> items;
  final String? message;

  EmployeeAdjustmentsState copyWith({
    NotesLoadStatus? status,
    List<EmployeeAdjustment>? items,
    String? message,
  }) {
    return EmployeeAdjustmentsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message,
    );
  }
}
