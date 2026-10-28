import 'package:el_karma_ph/features/dashboard_view/models/dashboard_models.dart';

enum AttendanceEntryKind { attended, absent, dayOff }

class AttendanceEntry {
  const AttendanceEntry({
    required this.day,
    required this.kind,
    this.shiftNumber,
    this.record,
  });

  final DateTime day;
  final AttendanceEntryKind kind;

  final int? shiftNumber;

  final ShiftAttendance? record;
}
