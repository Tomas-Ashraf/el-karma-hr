import 'package:el_karma_ph/core/utils/weekdays.dart';
import 'package:el_karma_ph/features/attendance_view.dart/models/attendance_entry.dart';
import 'package:el_karma_ph/features/dashboard_view/models/dashboard_models.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/settings_view/models/attendance_settings.dart';

class AttendanceCalculator {
  AttendanceCalculator._();

  static const _windowMargin = Duration(hours: 3);

  static DashboardData calculate({
    required List<EmployeeModel> employees,
    required Map<int, List<DateTime>> punchesByDevice,
    required AttendanceSettings settings,
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final records = <ShiftAttendance>[];

    for (final employee in employees) {
      if (!employee.isActive || employee.shifts.isEmpty) continue;
      final punches = punchesByDevice[employee.deviceId];
      if (punches == null || punches.isEmpty) continue;

      final slots = _buildSlots(
        employee,
        first: DateTime(today.year, today.month, today.day - 1),
        last: DateTime(today.year, today.month, today.day + 1),
        isReported: (day, end) =>
            day == today || (day.isBefore(today) && end.isAfter(today)),
      );

      for (var i = 0; i < slots.length; i++) {
        if (!slots[i].isReported) continue;
        final record = _evaluate(employee, slots, i, punches, settings);
        if (record != null) records.add(record);
      }
    }
    return DashboardData.fromRecords(records);
  }

  static List<AttendanceEntry> calculateRange({
    required EmployeeModel employee,
    required List<DateTime> punches,
    required AttendanceSettings settings,
    required DateTime from,
    required DateTime to,
    required DateTime now,
  }) {
    if (employee.shifts.isEmpty) return const [];

    final first = DateTime(from.year, from.month, from.day);
    final last = DateTime(to.year, to.month, to.day);

    final slots = _buildSlots(
      employee,
      first: DateTime(first.year, first.month, first.day - 1),
      last: DateTime(last.year, last.month, last.day + 1),
      isReported: (day, _) => !day.isBefore(first) && !day.isAfter(last),
    );

    final byDay = <DateTime, List<({_Slot slot, ShiftAttendance? record})>>{};
    for (var i = 0; i < slots.length; i++) {
      final slot = slots[i];
      if (!slot.isReported) continue;
      byDay.putIfAbsent(slot.day, () => []).add((
        slot: slot,
        record: _evaluate(employee, slots, i, punches, settings),
      ));
    }

    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    final multiShift = employee.shifts.length > 1;
    final entries = <AttendanceEntry>[];

    for (final day in days) {
      final items = byDay[day]!;
      final hasAttendance = items.any((e) => e.record != null);

      if (!hasAttendance) {
        if (employee.dayOff == weekdayKey(day)) {
          entries.add(
            AttendanceEntry(day: day, kind: AttendanceEntryKind.dayOff),
          );
        } else if (items.last.slot.end.isBefore(now)) {
          entries.add(
            AttendanceEntry(day: day, kind: AttendanceEntryKind.absent),
          );
        }
        continue;
      }

      for (final item in items) {
        final record = item.record;
        if (record != null) {
          entries.add(
            AttendanceEntry(
              day: day,
              kind: AttendanceEntryKind.attended,
              shiftNumber: multiShift ? item.slot.number : null,
              record: record,
            ),
          );
        } else if (item.slot.end.isBefore(now)) {
          entries.add(
            AttendanceEntry(
              day: day,
              kind: AttendanceEntryKind.absent,
              shiftNumber: item.slot.number,
            ),
          );
        }
      }
    }
    return entries;
  }

  static List<_Slot> _buildSlots(
    EmployeeModel employee, {
    required DateTime first,
    required DateTime last,
    required bool Function(DateTime day, DateTime end) isReported,
  }) {
    final slots = <_Slot>[];
    var day = first;
    while (!day.isAfter(last)) {
      for (var i = 0; i < employee.shifts.length; i++) {
        final shift = employee.shifts[i];
        final start = DateTime(
          day.year,
          day.month,
          day.day,
          shift.start.hour,
          shift.start.minute,
        );
        var end = DateTime(
          day.year,
          day.month,
          day.day,
          shift.end.hour,
          shift.end.minute,
        );
        if (!end.isAfter(start)) {
          end = DateTime(
            day.year,
            day.month,
            day.day + 1,
            shift.end.hour,
            shift.end.minute,
          );
        }
        slots.add(
          _Slot(
            number: i + 1,
            day: day,
            start: start,
            end: end,
            isReported: isReported(day, end),
          ),
        );
      }
      day = DateTime(day.year, day.month, day.day + 1);
    }
    slots.sort((a, b) => a.start.compareTo(b.start));
    return slots;
  }

  static ShiftAttendance? _evaluate(
    EmployeeModel employee,
    List<_Slot> slots,
    int i,
    List<DateTime> punches,
    AttendanceSettings settings,
  ) {
    final slot = slots[i];

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
    if (inWindow.isEmpty) return null;

    final shiftMid = _midpoint(slot.start, slot.end);
    final before = inWindow.where((p) => !p.isAfter(shiftMid)).toList();
    final after = inWindow.where((p) => p.isAfter(shiftMid)).toList();

    final checkIn = before.isEmpty ? null : before.first;
    final checkOut = after.isEmpty ? null : after.last;
    final lateAfter = slot.start.add(Duration(minutes: settings.lateMinutes));
    final earlyBefore = slot.end.subtract(
      Duration(minutes: settings.leaveEarlyMinutes),
    );

    return ShiftAttendance(
      employee: employee,
      shiftNumber: slot.number,
      shiftStart: slot.start,
      shiftEnd: slot.end,
      checkIn: checkIn,
      checkOut: checkOut,
      isLate: checkIn != null && checkIn.isAfter(lateAfter),
      leftEarly: checkOut != null && checkOut.isBefore(earlyBefore),
    );
  }

  static DateTime _midpoint(DateTime a, DateTime b) =>
      a.add(Duration(microseconds: b.difference(a).inMicroseconds ~/ 2));
}

class _Slot {
  const _Slot({
    required this.number,
    required this.day,
    required this.start,
    required this.end,
    required this.isReported,
  });

  final int number;

  final DateTime day;
  final DateTime start;
  final DateTime end;
  final bool isReported;
}
