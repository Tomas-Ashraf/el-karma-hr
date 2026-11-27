import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';

class SavedSalarySheet {
  const SavedSalarySheet({
    required this.id,
    required this.status,
    required this.from,
    required this.to,
    required this.paymentMethod,
    required this.isDelivery,
    required this.baseSalary,
    required this.attendedDays,
    required this.absentDays,
    required this.absenceDeduction,
    required this.lateMinutes,
    required this.lateDeduction,
    required this.deliveryOrders,
    required this.deliveryFees,
    required this.totalBonus,
    required this.totalDeduction,
    required this.net,
    required this.adjustments,
    this.paidAt,
  });

  final String id;
  final SalaryStatus status;
  final DateTime from;
  final DateTime to;
  final String paymentMethod;
  final bool isDelivery;
  final double baseSalary;
  final double attendedDays;
  final double absentDays;
  final double absenceDeduction;
  final int lateMinutes;
  final double lateDeduction;
  final int deliveryOrders;
  final double deliveryFees;
  final double totalBonus;
  final double totalDeduction;
  final double net;
  final List<EmployeeAdjustment> adjustments;
  final DateTime? paidAt;

  factory SavedSalarySheet.fromDocument(String id, Map<String, dynamic> d) {
    double n(String k) => (d[k] as num?)?.toDouble() ?? 0;
    DateTime? date(dynamic v) => v is Timestamp ? v.toDate() : null;

    return SavedSalarySheet(
      id: id,
      status: salaryStatusFromKey(d['status'] as String?),
      from: date(d['from']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      to: date(d['to']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      paymentMethod: (d['payment_method'] as String?) ?? '',
      isDelivery: d['is_delivery'] == true,
      baseSalary: n('base_salary'),
      attendedDays: n('attended_days'),
      absentDays: n('absent_days'),
      absenceDeduction: n('absence_deduction'),
      lateMinutes: (d['late_minutes'] as num?)?.toInt() ?? 0,
      lateDeduction: n('late_deduction'),
      deliveryOrders: (d['delivery_orders'] as num?)?.toInt() ?? 0,
      deliveryFees: n('delivery_fees'),
      totalBonus: n('total_bonus'),
      totalDeduction: n('total_deduction'),
      net: n('net'),
      adjustments: [
        for (final a in (d['adjustments'] as List?) ?? const [])
          if (a is Map)
            EmployeeAdjustment.fromDocument('', Map<String, dynamic>.from(a)),
      ],
      paidAt: date(d['paid_at']),
    );
  }
}
