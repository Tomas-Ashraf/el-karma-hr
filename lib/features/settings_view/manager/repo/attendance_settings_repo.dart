import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/settings_view/models/attendance_settings.dart';

/// بيقرا ويكتب إعدادات الحضور في document واحد: settings/attendance
class AttendanceSettingsRepo {
  AttendanceSettingsRepo({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection('settings').doc('attendance');

  Future<AttendanceSettings> getSettings() async {
    final snapshot = await _doc.get();
    final data = snapshot.data();
    if (data == null) return AttendanceSettings.defaults();
    return AttendanceSettings.fromMap(data);
  }

  Future<void> saveSettings(AttendanceSettings settings) {
    return _doc.set({
      ...settings.toMap(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
