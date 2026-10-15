import 'package:el_karma_ph/features/settings_view/models/attendance_settings.dart';

enum AttendanceSettingsStatus { loading, ready, saving, saved, failure }

class AttendanceSettingsState {
  const AttendanceSettingsState({
    required this.status,
    this.settings,
    this.message,
  });

  const AttendanceSettingsState.loading()
    : this(status: AttendanceSettingsStatus.loading);

  final AttendanceSettingsStatus status;

  /// آخر إعدادات اتحمّلت أو اتحفظت. null لو التحميل الأول لسه/فشل.
  final AttendanceSettings? settings;

  /// رسالة الخطأ (مع failure بس).
  final String? message;

  /// ملحوظة: message بتتمسح لو ما اتبعتتش.
  AttendanceSettingsState copyWith({
    AttendanceSettingsStatus? status,
    AttendanceSettings? settings,
    String? message,
  }) {
    return AttendanceSettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      message: message,
    );
  }
}
