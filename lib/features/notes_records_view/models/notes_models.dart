enum AdjustmentType { bonus, deduction }


class PersonalNote {
  const PersonalNote({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.colorIndex = 0,
  });

  final String id;
  final String title;
  final String body;
  final DateTime date;
  final int colorIndex;
}

class EmployeeAdjustment {
  const EmployeeAdjustment({
    required this.id,
    required this.employeeName,
    required this.type,
    required this.amount,
    required this.reason,
    required this.date,
  });

  final String id;
  final String employeeName;
  final AdjustmentType type;
  final double amount;
  final String reason;
  final DateTime date;

  bool get isBonus => type == AdjustmentType.bonus;
}

class NotesFilter {
  const NotesFilter({
    required this.employee,
    required this.from,
    required this.to,
  });

  final String employee;
  final DateTime from;
  final DateTime to;
}

// ───────────────────────── داتا وهمية (للتوضيح فقط) ─────────────────────────

const kDummyEmployees = [
  'Mina Samy',
  'Sara Adel',
  'Ahmed Hany',
  'Mariam Nabil',
  'Nour Ashraf',
];

DateTime _ago(int days) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - days);
}

final dummyPersonalNotes = <PersonalNote>[
  PersonalNote(
    id: 'n1',
    title: 'Order medicines',
    body: 'Call the supplier and order insulin and antibiotics before Thursday.',
    date: _ago(0),
    colorIndex: 0,
  ),
  PersonalNote(
    id: 'n2',
    title: 'Staff meeting',
    body: 'Discuss the new shifts schedule and the fingerprint device.',
    date: _ago(2),
    colorIndex: 2,
  ),
  PersonalNote(
    id: 'n3',
    title: 'Rent payment',
    body: 'Pay the pharmacy rent before the 5th of the month.',
    date: _ago(5),
    colorIndex: 3,
  ),
];

final dummyAdjustments = <EmployeeAdjustment>[
  EmployeeAdjustment(
    id: 'a1',
    employeeName: 'Mina Samy',
    type: AdjustmentType.bonus,
    amount: 300,
    reason: 'Excellent customer service',
    date: _ago(1),
  ),
  EmployeeAdjustment(
    id: 'a2',
    employeeName: 'Mina Samy',
    type: AdjustmentType.deduction,
    amount: 100,
    reason: 'Late 3 times this week',
    date: _ago(4),
  ),
  EmployeeAdjustment(
    id: 'a3',
    employeeName: 'Sara Adel',
    type: AdjustmentType.bonus,
    amount: 500,
    reason: 'Covered an extra shift',
    date: _ago(3),
  ),
  EmployeeAdjustment(
    id: 'a4',
    employeeName: 'Ahmed Hany',
    type: AdjustmentType.deduction,
    amount: 250,
    reason: 'Damaged stock item',
    date: _ago(6),
  ),
  EmployeeAdjustment(
    id: 'a5',
    employeeName: 'Mariam Nabil',
    type: AdjustmentType.bonus,
    amount: 150,
    reason: 'Best sales of the week',
    date: _ago(8),
  ),
];
