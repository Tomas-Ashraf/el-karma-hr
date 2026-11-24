// بيانات وهمية للـ UI بس — هتتبدل بداتا حقيقية بعدين.

class SalaryEmployee {
  const SalaryEmployee({
    required this.id,
    required this.name,
    required this.job,
    required this.salary,
  });

  final String id;
  final String name;
  final String job;
  final double salary;
}

class SalaryRecord {
  const SalaryRecord({
    required this.id,
    required this.from,
    required this.to,
    required this.attendedDays,
    required this.absentDays,
    required this.lateMinutes,
    required this.bonus,
    required this.deduction,
    required this.netSalary,
  });

  final String id;
  final DateTime from;
  final DateTime to;
  final int attendedDays;
  final int absentDays;
  final int lateMinutes;
  final double bonus;
  final double deduction;
  final double netSalary;
}

const kDummyEmployees = <SalaryEmployee>[
  SalaryEmployee(id: '1', name: 'Mina Samy', job: 'Pharmacist', salary: 6000),
  SalaryEmployee(id: '2', name: 'Sara Adel', job: 'Cashier', salary: 4500),
  SalaryEmployee(id: '3', name: 'Ahmed Hany', job: 'Delivery', salary: 3800),
  SalaryEmployee(id: '4', name: 'Mariam Nabil', job: 'Pharmacist', salary: 6200),
];

final kDummyRecords = <SalaryRecord>[
  SalaryRecord(
    id: 'r1',
    from: DateTime(2026, 10, 1),
    to: DateTime(2026, 10, 31),
    attendedDays: 26,
    absentDays: 1,
    lateMinutes: 45,
    bonus: 300,
    deduction: 150,
    netSalary: 6050,
  ),
  SalaryRecord(
    id: 'r2',
    from: DateTime(2026, 9, 1),
    to: DateTime(2026, 9, 30),
    attendedDays: 25,
    absentDays: 2,
    lateMinutes: 90,
    bonus: 0,
    deduction: 400,
    netSalary: 5450,
  ),
  SalaryRecord(
    id: 'r3',
    from: DateTime(2026, 8, 1),
    to: DateTime(2026, 8, 31),
    attendedDays: 27,
    absentDays: 0,
    lateMinutes: 0,
    bonus: 500,
    deduction: 0,
    netSalary: 6500,
  ),
];
