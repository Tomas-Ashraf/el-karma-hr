import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';
import 'package:el_karma_ph/features/count_salary_view/models/saved_salary_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalarySheetsRepo {
  SalarySheetsRepo({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> _root(String employeeId) =>
      _db.collection(kSalarySheetsCollection).doc(employeeId);

  CollectionReference<Map<String, dynamic>> _sheets(String employeeId) =>
      _root(employeeId).collection('sheets');

  Future<Map<String, SalaryStatus>> getStatuses(String employeeId) async {
    final snapshot = await _sheets(employeeId).get();
    return {
      for (final doc in snapshot.docs)
        doc.id: salaryStatusFromKey(doc.data()['status'] as String?),
    };
  }

  Future<Map<String, dynamic>?> getSaved(
    String employeeId,
    String recordId,
  ) async {
    final doc = await _sheets(employeeId).doc(recordId).get();
    return doc.data();
  }

  Future<List<SavedSalarySheet>> getHistory(String employeeId) async {
    final snapshot = await _sheets(employeeId)
        .orderBy('from', descending: true)
        .get();
    return [
      for (final doc in snapshot.docs)
        SavedSalarySheet.fromDocument(doc.id, doc.data()),
    ];
  }

  Future<void> save(
    SalarySheet s, {
    required SalaryStatus status,
    bool first = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cashier = prefs.getString('userName');
    final paid = status == SalaryStatus.paid;

    final batch = _db.batch();
    batch.set(_root(s.employee.id), {
      'employee_name': s.employee.name,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    batch.set(_sheets(s.employee.id).doc(s.record.id), {
      'employee_id': s.employee.id,
      'employee_name': s.employee.name,
      'job': s.employee.job,
      'phone_number': s.employee.phoneNumber,
      'payment_method': s.employee.paymentMethod,
      'from': Timestamp.fromDate(s.record.from),
      'to': Timestamp.fromDate(s.record.to),
      'status': paid ? 'paid' : 'calculated',
      'is_delivery': s.isDelivery,
      'base_salary': s.baseSalary,
      'daily_rate': s.dailyRate,
      'attended_days': s.attendedDays,
      'absent_days': s.absentDays,
      'off_days': s.offDays,
      'absence_deduction': s.absenceDeduction,
      'late_minutes': s.lateMinutes,
      'deduction_per_minute': s.deductionPerMinute,
      'late_deduction': s.lateDeduction,
      'delivery_orders': s.deliveryOrders,
      'delivery_fees': s.deliveryFees,
      'total_bonus': s.totalBonus,
      'total_deduction': s.totalDeduction,
      'net': s.net,
      'edited_fields': s.editedFields.toList(),
      'adjustments': [
        for (final a in s.adjustments)
          {
            'type': a.type.name,
            'amount': a.amount,
            'reason': a.reason,
            'date': Timestamp.fromDate(a.date),
          },
      ],
      'updated_at': FieldValue.serverTimestamp(),
      if (first) 'calculated_at': FieldValue.serverTimestamp(),
      if (paid) ...{
        'paid_at': FieldValue.serverTimestamp(),
        'paid_by': _auth.currentUser?.uid,
        'paid_by_name': (cashier == null || cashier.isEmpty) ? null : cashier,
      },
    }, SetOptions(merge: true));

    await batch.commit();
  }
}

SalarySheet applySaved(SalarySheet fresh, Map<String, dynamic>? saved) {
  if (saved == null) return fresh;

  final status = salaryStatusFromKey(saved['status'] as String?);
  final paid = status == SalaryStatus.paid;
  final edited = {
    for (final f in (saved['edited_fields'] as List?) ?? const []) '$f',
  };
  bool use(String field) => paid || edited.contains(field);
  double? num_(String key) => (saved[key] as num?)?.toDouble();

  return fresh.copyWith(
    baseSalary: use('baseSalary') ? num_('base_salary') : null,
    absentDays: use('absentDays') ? num_('absent_days') : null,
    lateDeduction: use('lateDeduction') ? num_('late_deduction') : null,
    deliveryOrders: use('deliveryOrders')
        ? (saved['delivery_orders'] as num?)?.toInt()
        : null,
    bonusOverride: use('bonus') ? num_('total_bonus') : null,
    deductionOverride: use('deduction') ? num_('total_deduction') : null,
    status: status,
    editedFields: edited,
  );
}
