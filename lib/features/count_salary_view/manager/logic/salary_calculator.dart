import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/employee_jobs.dart';
import 'package:el_karma_ph/features/attendance_view.dart/models/attendance_entry.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';

class SalaryCalculator {
  SalaryCalculator._();

  static SalarySheet calculate({
    required EmployeeModel employee,
    required RecordPreview record,
    required List<EmployeeAdjustment> adjustments,
    required int deliveryOrdersCount,
    required double deductionPerMinute,
  }) {
    final isDelivery = normalizeJob(employee.job) == kDeliveryJob;
    final dailyRate = employee.salary / kSalaryMonthDays;
    final sortedAdjustments = [...adjustments]
      ..sort((a, b) => a.date.compareTo(b.date));
    if (isDelivery) {
      return SalarySheet(
        employee: employee,
        record: record,
        isDelivery: true,
        dailyRate: dailyRate,
        attendedDays: 0,
        absentDays: 0,
        offDays: 0,
        earnedSalary: employee.salary,
        lateMinutes: 0,
        deductionPerMinute: deductionPerMinute,
        lateDeduction: 0,
        deliveryOrders: deliveryOrdersCount,
        deliveryFees: roundMoney(deliveryOrdersCount * kDeliveryFeePerOrder),
        adjustments: sortedAdjustments,
      );
    }

    final days = countDays(employee, record);
    final lateMinutes = record.lateMinutesTotal;

    return SalarySheet(
      employee: employee,
      record: record,
      isDelivery: false,
      dailyRate: dailyRate,
      attendedDays: days.attended,
      absentDays: days.absent,
      offDays: days.off,
      earnedSalary: roundMoney((days.attended + days.off) * dailyRate),
      lateMinutes: lateMinutes,
      deductionPerMinute: deductionPerMinute,
      lateDeduction: roundMoney(lateMinutes * deductionPerMinute),
      deliveryOrders: 0,
      deliveryFees: 0,
      adjustments: sortedAdjustments,
    );
  }

  static ({double attended, double absent, int off}) countDays(
    EmployeeModel employee,
    RecordPreview record,
  ) {
    var shiftCount = employee.shifts.isEmpty ? 1 : employee.shifts.length;
    for (final e in record.entries) {
      final n = e.shiftNumber;
      if (n != null && n > shiftCount) shiftCount = n;
    }

    var attended = 0.0;
    var absent = 0.0;
    var off = 0;
    for (final e in record.entries) {
      final weight = e.shiftNumber == null ? 1.0 : 1.0 / shiftCount;
      switch (e.kind) {
        case AttendanceEntryKind.attended:
          attended += weight;
        case AttendanceEntryKind.absent:
          absent += weight;
        case AttendanceEntryKind.dayOff:
          off++;
      }
    }
    return (attended: attended, absent: absent, off: off);
  }
}
