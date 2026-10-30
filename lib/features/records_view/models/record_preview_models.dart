import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/attendance_view.dart/models/attendance_entry.dart';
import 'package:el_karma_ph/features/dashboard_view/models/dashboard_models.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';

class RecordsEmployee {
  const RecordsEmployee({required this.id, required this.name});

  final String id;
  final String name;
}

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

  int get lateMinutesTotal {
    var total = 0;
    for (final e in entries) {
      final r = e.record;
      if (r != null && r.isLate) total += r.minutesLate;
    }
    return total;
  }

  factory RecordPreview.fromFirestore(
    String employeeId,
    String id,
    Map<String, dynamic> data,
  ) {
    final name = (data['employee_name'] as String?) ?? '';

    final employee = EmployeeModel(
      id: employeeId,
      name: name,
      email: '',
      job: '',
      userType: '',
      phoneNumber: '',
      salary: 0,
      paymentMethod: '',
      userStatus: 'active',
      deviceId: 0,
      shifts: const [],
    );

    final raw = <Map<String, dynamic>>[
      for (final item in (data['entries'] as List?) ?? const [])
        if (item is Map) Map<String, dynamic>.from(item),
    ];

    final multiShift = raw.any(
      (m) => ((m['shift_number'] as num?)?.toInt() ?? 1) > 1,
    );

    return RecordPreview(
      id: id,
      employeeId: employeeId,
      employeeName: name,
      from: _date(data['from']),
      to: _date(data['to']),
      entries: [for (final m in raw) _entry(employee, m, multiShift)],
    );
  }

  static AttendanceEntry _entry(
    EmployeeModel employee,
    Map<String, dynamic> m,
    bool multiShift,
  ) {
    final day = _date(m['day']);
    final shiftNumber = (m['shift_number'] as num?)?.toInt();
    final kind = switch (m['kind']) {
      'absent' => AttendanceEntryKind.absent,
      'day_off' => AttendanceEntryKind.dayOff,
      _ => AttendanceEntryKind.attended,
    };

    if (kind != AttendanceEntryKind.attended) {
      return AttendanceEntry(day: day, kind: kind, shiftNumber: shiftNumber);
    }

    final record = ShiftAttendance(
      employee: employee,
      shiftNumber: shiftNumber ?? 1,
      shiftStart: _dateOrNull(m['shift_start']) ?? day,
      shiftEnd: _dateOrNull(m['shift_end']) ?? day,
      checkIn: _dateOrNull(m['check_in']),
      checkOut: _dateOrNull(m['check_out']),
      isLate: m['is_late'] == true,
      leftEarly: m['left_early'] == true,
    );

    return AttendanceEntry(
      day: day,
      kind: kind,
      shiftNumber: multiShift ? record.shiftNumber : null,
      record: record,
    );
  }

  static DateTime? _dateOrNull(dynamic value) =>
      value is Timestamp ? value.toDate() : null;

  static DateTime _date(dynamic value) =>
      _dateOrNull(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}
