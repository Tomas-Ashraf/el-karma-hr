import 'package:el_karma_ph/features/attendance_view.dart/models/attendance_entry.dart';
import 'package:el_karma_ph/features/dashboard_view/models/dashboard_models.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';

/// بيانات تجريبية للـ UI فقط — تتشال لما نربط الشاشة بـ Firestore.
const kMockEmployees = [
  RecordsEmployee(id: 'e1', name: 'أحمد علي'),
  RecordsEmployee(id: 'e2', name: 'منى محمود'),
  RecordsEmployee(id: 'e3', name: 'كريم سمير'),
];

/// السجلات التجريبية لكل موظف. كريم (e3) ملوش سجلات عشان نجرّب الحالة الفاضية.
Map<String, List<RecordPreview>> buildMockRecords() {
  const attended = AttendanceEntryKind.attended;
  const absent = AttendanceEntryKind.absent;
  const dayOff = AttendanceEntryKind.dayOff;

  return {
    'e1': [
      _record(
        id: 'r1',
        employee: kMockEmployees[0],
        from: DateTime(2026, 10, 1),
        days: const [
          (attended, -2, 3),
          (dayOff, 0, 0),
          (attended, 18, 0),
          (attended, 0, -25),
          (absent, 0, 0),
          (attended, -5, 10),
          (attended, 7, 1),
        ],
      ),
      _record(
        id: 'r2',
        employee: kMockEmployees[0],
        from: DateTime(2026, 10, 8),
        days: const [
          (attended, 0, 5),
          (dayOff, 0, 0),
          (attended, 3, 2),
          (attended, -1, 0),
          (attended, 12, -10),
          (attended, 0, 0),
          (attended, -3, 15),
        ],
      ),
    ],
    'e2': [
      _record(
        id: 'r3',
        employee: kMockEmployees[1],
        from: DateTime(2026, 10, 1),
        days: const [
          (attended, 0, 0),
          (attended, 25, 0),
          (absent, 0, 0),
          (attended, -4, 6),
          (dayOff, 0, 0),
        ],
      ),
    ],
    'e3': [],
  };
}

RecordPreview _record({
  required String id,
  required RecordsEmployee employee,
  required DateTime from,
  required List<(AttendanceEntryKind, int, int)> days,
}) {
  final model = EmployeeModel(
    id: employee.id,
    name: employee.name,
    email: '',
    job: '',
    userType: 'employee',
    phoneNumber: '',
    salary: 0,
    paymentMethod: '',
    userStatus: 'active',
    deviceId: 0,
    shifts: const [],
  );

  final entries = <AttendanceEntry>[];
  for (var i = 0; i < days.length; i++) {
    final (kind, inOffset, outOffset) = days[i];
    final day = DateTime(from.year, from.month, from.day + i);

    if (kind != AttendanceEntryKind.attended) {
      entries.add(AttendanceEntry(day: day, kind: kind));
      continue;
    }

    final shiftStart = DateTime(day.year, day.month, day.day, 9);
    final shiftEnd = DateTime(day.year, day.month, day.day, 17);
    entries.add(
      AttendanceEntry(
        day: day,
        kind: kind,
        shiftNumber: 1,
        record: ShiftAttendance(
          employee: model,
          shiftNumber: 1,
          shiftStart: shiftStart,
          shiftEnd: shiftEnd,
          checkIn: shiftStart.add(Duration(minutes: inOffset)),
          checkOut: shiftEnd.add(Duration(minutes: outOffset)),
          isLate: inOffset > 5,
          leftEarly: outOffset < -5,
        ),
      ),
    );
  }

  return RecordPreview(
    id: id,
    employeeId: employee.id,
    employeeName: employee.name,
    from: from,
    to: DateTime(from.year, from.month, from.day + days.length - 1),
    entries: entries,
  );
}
