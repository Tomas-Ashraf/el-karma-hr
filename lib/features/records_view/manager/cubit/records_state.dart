import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';

enum RecordsStatus { loadingEmployees, ready, loadingRecords, success, failure }

class RecordsState {
  const RecordsState({
    required this.status,
    this.employees = const [],
    this.selected,
    this.records = const [],
    this.message,
  });

  final RecordsStatus status;
  final List<RecordsEmployee> employees;
  final RecordsEmployee? selected;
  final List<RecordPreview> records;
  final String? message;

  RecordsState copyWith({
    RecordsStatus? status,
    List<RecordsEmployee>? employees,
    RecordsEmployee? selected,
    List<RecordPreview>? records,
    String? message,
  }) {
    return RecordsState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      selected: selected ?? this.selected,
      records: records ?? this.records,
      message: message,
    );
  }
}
