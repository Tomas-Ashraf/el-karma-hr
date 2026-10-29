import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/attendance_view.dart/models/attendance_entry.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/settings_view/models/attendance_settings.dart';

class AttendanceRecord {
  const AttendanceRecord({
    required this.employee,
    required this.from,
    required this.to,
    required this.entries,
    required this.settings,
  });

  final EmployeeModel employee;
  final DateTime from;
  final DateTime to;
  final List<AttendanceEntry> entries;

  final AttendanceSettings settings;

  String get periodId => '${_ymd(from)}_${_ymd(to)}';

  Map<String, dynamic> employeeMap() => {
    'name': employee.name,
    'email': employee.email,
    'job': employee.job,
    'device_id': employee.deviceId,
    'updated_at': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> toMap() {
    var attendedShifts = 0;
    var absent = 0;
    var dayOff = 0;
    var lateCount = 0;
    var lateMinutes = 0;
    var earlyCount = 0;
    var earlyMinutes = 0;

    for (final e in entries) {
      if (e.kind == AttendanceEntryKind.absent) {
        absent++;
      } else if (e.kind == AttendanceEntryKind.dayOff) {
        dayOff++;
      } else {
        attendedShifts++;
        final r = e.record;
        if (r != null && r.isLate) {
          lateCount++;
          lateMinutes += r.minutesLate;
        }
        if (r != null && r.leftEarly) {
          earlyCount++;
          earlyMinutes += r.minutesEarly;
        }
      }
    }

    return {
      'employee_id': employee.id,
      'employee_name': employee.name,
      'from': Timestamp.fromDate(_dayOnly(from)),
      'to': Timestamp.fromDate(_dayOnly(to)),
      'settings': {
        'late_minutes': settings.lateMinutes,
        'leave_early_minutes': settings.leaveEarlyMinutes,
        'deduction_per_minute': settings.deductionPerMinute,
      },
      'summary': {
        'attended_shifts': attendedShifts,
        'absent_count': absent,
        'day_off_count': dayOff,
        'late_count': lateCount,
        'late_minutes_total': lateMinutes,
        'left_early_count': earlyCount,
        'left_early_minutes_total': earlyMinutes,
      },
      'entries': [for (final e in entries) _entryMap(e)],
      'saved_at': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> _entryMap(AttendanceEntry e) {
    final r = e.record;
    return {
      'day': Timestamp.fromDate(_dayOnly(e.day)),
      'kind': switch (e.kind) {
        AttendanceEntryKind.attended => 'attended',
        AttendanceEntryKind.absent => 'absent',
        AttendanceEntryKind.dayOff => 'day_off',
      },
      'shift_number': r?.shiftNumber ?? e.shiftNumber,
      if (r != null) ...{
        'shift_start': Timestamp.fromDate(r.shiftStart),
        'shift_end': Timestamp.fromDate(r.shiftEnd),
        'check_in': _ts(r.checkIn),
        'check_out': _ts(r.checkOut),
        'is_late': r.isLate,
        'minutes_late': r.minutesLate,
        'left_early': r.leftEarly,
        'minutes_early': r.minutesEarly,
      },
    };
  }

  static Timestamp? _ts(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _ymd(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}'
      '${d.day.toString().padLeft(2, '0')}';
}
