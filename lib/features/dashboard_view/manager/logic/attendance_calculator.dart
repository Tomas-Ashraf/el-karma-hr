import 'package:el_karma_ph/features/dashboard_view/models/dashboard_models.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/settings_view/models/attendance_settings.dart';

class AttendanceCalculator {
  AttendanceCalculator._();

  static const _windowMargin = Duration(hours: 3);

  static const _minStay = Duration(minutes: 30);

  static DashboardData calculate({
    required List<EmployeeModel> employees,
    required Map<int, List<DateTime>> punchesByDevice,
    required AttendanceSettings settings,
    required DateTime now,
  }) {
    final records = <ShiftAttendance>[];

    for (final employee in employees) {
      if (!employee.isActive || employee.shifts.isEmpty) continue;
      final punches = punchesByDevice[employee.deviceId];
      if (punches == null || punches.isEmpty) continue;
      records.addAll(_forEmployee(employee, punches, settings, now));
    }
    return DashboardData.fromRecords(records);
  }

  static List<ShiftAttendance> _forEmployee(
    EmployeeModel employee,
    List<DateTime> punches,
    AttendanceSettings settings,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);

    final slots = <_Slot>[];
    for (var offset = -1; offset <= 1; offset++) {
      for (var i = 0; i < employee.shifts.length; i++) {
        final shift = employee.shifts[i];
        final day = today.day + offset;
        final start = DateTime(
          today.year,
          today.month,
          day,
          shift.start.hour,
          shift.start.minute,
        );
        var end = DateTime(
          today.year,
          today.month,
          day,
          shift.end.hour,
          shift.end.minute,
        );
        if (!end.isAfter(start)) {
          end = DateTime(
            today.year,
            today.month,
            day + 1,
            shift.end.hour,
            shift.end.minute,
          );
        }
        slots.add(
          _Slot(
            number: i + 1,
            start: start,
            end: end,
            isReported: offset == 0 || (offset == -1 && end.isAfter(today)),
          ),
        );
      }
    }
    slots.sort((a, b) => a.start.compareTo(b.start));

    final result = <ShiftAttendance>[];
    for (var i = 0; i < slots.length; i++) {
      final slot = slots[i];
      if (!slot.isReported) continue;

      var lower = slot.start.subtract(_windowMargin);
      if (i > 0) {
        final mid = _midpoint(slots[i - 1].end, slot.start);
        if (mid.isAfter(lower)) lower = mid;
      }
      if (lower.isAfter(slot.start)) lower = slot.start;

      var upper = slot.end.add(_windowMargin);
      if (i < slots.length - 1) {
        final mid = _midpoint(slot.end, slots[i + 1].start);
        if (mid.isBefore(upper)) upper = mid;
      }
      if (upper.isBefore(slot.end)) upper = slot.end;

      final inWindow =
          punches.where((p) => !p.isBefore(lower) && !p.isAfter(upper)).toList()
            ..sort();
      if (inWindow.isEmpty) continue;

      final checkIn = inWindow.first;
      final last = inWindow.last;
      final checkOut = last.difference(checkIn) >= _minStay ? last : null;
      final lateAfter = slot.start.add(Duration(minutes: settings.lateMinutes));

      result.add(
        ShiftAttendance(
          employee: employee,
          shiftNumber: slot.number,
          shiftStart: slot.start,
          shiftEnd: slot.end,
          checkIn: checkIn,
          checkOut: checkOut,
          isLate: checkIn.isAfter(lateAfter),
        ),
      );
    }
    return result;
  }

  static DateTime _midpoint(DateTime a, DateTime b) =>
      a.add(Duration(microseconds: b.difference(a).inMicroseconds ~/ 2));
}

class _Slot {
  const _Slot({
    required this.number,
    required this.start,
    required this.end,
    required this.isReported,
  });

  final int number;
  final DateTime start;
  final DateTime end;
  final bool isReported;
}
