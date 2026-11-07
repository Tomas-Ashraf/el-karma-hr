import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';

enum AdjustmentType { bonus, deduction }

DateTime _dateOf(dynamic value) => value is Timestamp
    ? value.toDate()
    : DateTime.fromMillisecondsSinceEpoch(0);

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

  factory PersonalNote.fromDocument(String id, Map<String, dynamic> data) {
    return PersonalNote(
      id: id,
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? '',
      date: _dateOf(data['date']),
      colorIndex: (data['color_index'] as num?)?.toInt() ?? 0,
    );
  }
}

class EmployeeAdjustment {
  const EmployeeAdjustment({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.amount,
    required this.reason,
    required this.date,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final AdjustmentType type;
  final double amount;
  final String reason;
  final DateTime date;

  bool get isBonus => type == AdjustmentType.bonus;

  factory EmployeeAdjustment.fromDocument(
    String id,
    Map<String, dynamic> data,
  ) {
    return EmployeeAdjustment(
      id: id,
      employeeId: (data['employee_id'] as String?) ?? '',
      employeeName: (data['employee_name'] as String?) ?? '',
      type: data['type'] == 'deduction'
          ? AdjustmentType.deduction
          : AdjustmentType.bonus,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      reason: (data['reason'] as String?) ?? '',
      date: _dateOf(data['date']),
    );
  }
}

typedef AdjustmentDraft = ({
  EmployeeModel employee,
  AdjustmentType type,
  double amount,
  String reason,
  DateTime date,
});

class NotesFilter {
  const NotesFilter({
    required this.employee,
    required this.from,
    required this.to,
  });

  final EmployeeModel employee;
  final DateTime from;
  final DateTime to;
}

class NotesPeriod {
  const NotesPeriod({required this.from, required this.to});

  final DateTime from;
  final DateTime to;
}

class EmployeeTotals {
  const EmployeeTotals({
    required this.employeeId,
    required this.name,
    required this.bonus,
    required this.deduction,
  });

  final String employeeId;
  final String name;
  final double bonus;
  final double deduction;
}

class NotesEmployeeArgs {
  const NotesEmployeeArgs({
    required this.employeeId,
    required this.name,
    required this.from,
    required this.to,
  });

  final String employeeId;
  final String name;
  final DateTime from;
  final DateTime to;
}

class NotesSummary {
  const NotesSummary(this.employees);

  final List<EmployeeTotals> employees;

  double get totalBonus => employees.fold(0.0, (s, e) => s + e.bonus);
  double get totalDeduction => employees.fold(0.0, (s, e) => s + e.deduction);
}
