import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';

double roundMoney(double value) => (value * 100).roundToDouble() / 100;

/// 26 -> "26"، و 25.5 -> "25.5".
String formatDays(double value) =>
    value % 1 == 0 ? '${value.toInt()}' : value.toStringAsFixed(1);

/// شيت مرتب موظف لفترة record.
class SalarySheet {
  const SalarySheet({
    required this.employee,
    required this.record,
    required this.isDelivery,
    required this.dailyRate,
    required this.attendedDays,
    required this.absentDays,
    required this.offDays,
    required this.earnedSalary,
    required this.lateMinutes,
    required this.deductionPerMinute,
    required this.lateDeduction,
    required this.deliveryOrders,
    required this.deliveryFees,
    required this.adjustments,
  });

  final EmployeeModel employee;
  final RecordPreview record;
  final bool isDelivery;

  final double dailyRate;

  final double attendedDays;
  final double absentDays;

  final int offDays;

  final double earnedSalary;

  final int lateMinutes;
  final double deductionPerMinute;
  final double lateDeduction;

  final int deliveryOrders;
  final double deliveryFees;

  final List<EmployeeAdjustment> adjustments;

  double get baseSalary => employee.salary;

  double get paidDays => attendedDays + offDays;

  double get totalBonus => roundMoney(
    adjustments.where((a) => a.isBonus).fold(0.0, (s, a) => s + a.amount),
  );

  double get totalDeduction => roundMoney(
    adjustments.where((a) => !a.isBonus).fold(0.0, (s, a) => s + a.amount),
  );

  double get net => roundMoney(
    earnedSalary + deliveryFees + totalBonus - lateDeduction - totalDeduction,
  );
}
