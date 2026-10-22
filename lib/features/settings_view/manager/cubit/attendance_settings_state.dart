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

  final AttendanceSettings? settings;

  final String? message;

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
