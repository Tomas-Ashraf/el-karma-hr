import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/employees_view/repos/employees_repo.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesRepo {
  NotesRepo({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    EmployeesRepo? employeesRepo,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _employeesRepo = employeesRepo ?? EmployeesRepo();

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final EmployeesRepo _employeesRepo;

  DocumentReference<Map<String, dynamic>> _root(String name) =>
      _db.collection(kNotesCollection).doc(name);

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _personal =>
      _root(kNotesPersonalDoc).collection(_uid);

  CollectionReference<Map<String, dynamic>> _employeeNotes(String employeeId) =>
      _root(kNotesEmployeesDoc).collection(employeeId);

  void _ensureRoot(WriteBatch batch, String name) => batch.set(_root(name), {
    'updated_at': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  Future<List<PersonalNote>> getPersonalNotes() async {
    final snapshot = await _personal.orderBy('date', descending: true).get();
    return [
      for (final doc in snapshot.docs)
        PersonalNote.fromDocument(doc.id, doc.data()),
    ];
  }

  Future<void> savePersonalNote({
    String? id,
    required String title,
    required String body,
    required int colorIndex,
  }) async {
    final col = _personal;
    final ref = id == null ? col.doc() : col.doc(id);

    final batch = _db.batch();
    _ensureRoot(batch, kNotesPersonalDoc);
    batch.set(ref, {
      'title': title,
      'body': body,
      'color_index': colorIndex,
      'date': Timestamp.now(),
      if (id == null) 'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> deletePersonalNote(String id) => _personal.doc(id).delete();

  Future<List<EmployeeModel>> getEmployees() => _employeesRepo.getEmployees();

  Future<List<EmployeeAdjustment>> getAdjustments(
    String employeeId,
    DateTime from,
    DateTime to,
  ) async {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day + 1);

    final snapshot = await _employeeNotes(employeeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();

    return [
      for (final doc in snapshot.docs)
        EmployeeAdjustment.fromDocument(doc.id, doc.data()),
    ];
  }

  Future<void> addAdjustment(AdjustmentDraft draft) async {
    final ref = _employeeNotes(draft.employee.id).doc();

    final batch = _db.batch();
    _ensureRoot(batch, kNotesEmployeesDoc);
    batch.set(ref, {
      'employee_id': draft.employee.id,
      'employee_name': draft.employee.name,
      'type': draft.type.name,
      'amount': draft.amount,
      'reason': draft.reason,
      'date': Timestamp.fromDate(draft.date),
      'created_by': _auth.currentUser?.uid,
      'created_at': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> deleteAdjustment(EmployeeAdjustment item) =>
      _employeeNotes(item.employeeId).doc(item.id).delete();
  Future<void> updateAdjustment(
    EmployeeAdjustment item,
    AdjustmentDraft draft,
  ) {
    return _employeeNotes(item.employeeId).doc(item.id).update({
      'type': draft.type.name,
      'amount': draft.amount,
      'reason': draft.reason,
      'date': Timestamp.fromDate(draft.date),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<NotesSummary> getSummary(
    List<EmployeeModel> employees,
    DateTime from,
    DateTime to,
  ) async {
    final all = await Future.wait(
      employees.map((employee) async {
        final items = await getAdjustments(employee.id, from, to);
        if (items.isEmpty) return null;
        return EmployeeTotals(
          employeeId: employee.id,
          name: employee.name,
          bonus: items
              .where((i) => i.isBonus)
              .fold(0.0, (s, i) => s + i.amount),
          deduction: items
              .where((i) => !i.isBonus)
              .fold(0.0, (s, i) => s + i.amount),
        );
      }),
    );
    return NotesSummary([for (final totals in all) ?totals]);
  }
}

String notesErrorKey(Object error, String fallback) =>
    error is FirebaseException && error.code == 'unavailable'
    ? 'error.no_internet'
    : fallback;
