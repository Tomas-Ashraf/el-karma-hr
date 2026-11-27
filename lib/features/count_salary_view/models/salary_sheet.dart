import 'package:el_karma_ph/constants.dart';
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
    required this.baseSalary,
    required this.attendedDays,
    required this.absentDays,
    required this.offDays,
    required this.lateMinutes,
    required this.deductionPerMinute,
    required this.lateDeduction,
    required this.deliveryOrders,
    required this.adjustments,
    this.bonusOverride,
    this.deductionOverride,
  });

  final EmployeeModel employee;
  final RecordPreview record;
  final bool isDelivery;

  /// المرتب الأساسي (قابل للتعديل من الشيت).
  final double baseSalary;

  final double attendedDays;
  final double absentDays;
  final int offDays;

  final int lateMinutes;
  final double deductionPerMinute;
  final double lateDeduction;

  final int deliveryOrders;
  final List<EmployeeAdjustment> adjustments;

  /// قيم المكافآت/الخصومات لو اتعدلت يدويًا (بدل مجموع الملاحظات).
  final double? bonusOverride;
  final double? deductionOverride;

  double get dailyRate => baseSalary / kSalaryMonthDays;

  double get absenceDeduction => roundMoney(absentDays * dailyRate);

  /// المرتب بعد خصم الغياب.
  double get earnedSalary => roundMoney(baseSalary - absenceDeduction);

  double get deliveryFees => roundMoney(deliveryOrders * kDeliveryFeePerOrder);

  double get totalBonus =>
      bonusOverride ??
      roundMoney(
        adjustments.where((a) => a.isBonus).fold(0.0, (s, a) => s + a.amount),
      );

  double get totalDeduction =>
      deductionOverride ??
      roundMoney(
        adjustments.where((a) => !a.isBonus).fold(0.0, (s, a) => s + a.amount),
      );

  double get net => roundMoney(
    earnedSalary + deliveryFees + totalBonus - lateDeduction - totalDeduction,
  );

  SalarySheet copyWith({
    double? baseSalary,
    double? absentDays,
    double? lateDeduction,
    int? deliveryOrders,
    double? bonusOverride,
    double? deductionOverride,
  }) {
    return SalarySheet(
      employee: employee,
      record: record,
      isDelivery: isDelivery,
      baseSalary: baseSalary ?? this.baseSalary,
      attendedDays: attendedDays,
      absentDays: absentDays ?? this.absentDays,
      offDays: offDays,
      lateMinutes: lateMinutes,
      deductionPerMinute: deductionPerMinute,
      lateDeduction: lateDeduction ?? this.lateDeduction,
      deliveryOrders: deliveryOrders ?? this.deliveryOrders,
      adjustments: adjustments,
      bonusOverride: bonusOverride ?? this.bonusOverride,
      deductionOverride: deductionOverride ?? this.deductionOverride,
    );
  }
}
