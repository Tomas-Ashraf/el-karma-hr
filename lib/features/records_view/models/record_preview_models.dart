import 'package:el_karma_ph/features/attendance_view.dart/models/attendance_entry.dart';

/// موظف في قائمة اختيار شاشة السجلات (بيانات تجريبية للـ UI فقط).
class RecordsEmployee {
  const RecordsEmployee({required this.id, required this.name});

  final String id;
  final String name;
}

/// سجل حضور وانصراف محفوظ لفترة معيّنة (بيانات تجريبية للـ UI فقط).
class RecordPreview {
  const RecordPreview({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.from,
    required this.to,
    required this.entries,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime from;
  final DateTime to;
  final List<AttendanceEntry> entries;

  int get daysCount => entries.length;

  int get absentCount =>
      entries.where((e) => e.kind == AttendanceEntryKind.absent).length;

  /// إجمالي دقايق التأخير في كل أيام السجل (مش عدد الأيام).
  int get lateMinutesTotal {
    var total = 0;
    for (final e in entries) {
      final r = e.record;
      if (r != null && r.isLate) total += r.minutesLate;
    }
    return total;
  }
}
