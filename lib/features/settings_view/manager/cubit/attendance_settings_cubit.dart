import 'dart:developer' show log;

import 'package:el_karma_ph/features/settings_view/manager/cubit/attendance_settings_state.dart';
import 'package:el_karma_ph/features/settings_view/manager/repo/attendance_settings_repo.dart';
import 'package:el_karma_ph/features/settings_view/models/attendance_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceSettingsCubit extends Cubit<AttendanceSettingsState> {
  AttendanceSettingsCubit({AttendanceSettingsRepo? repo})
    : _repo = repo ?? AttendanceSettingsRepo(),
      super(const AttendanceSettingsState.loading());

  final AttendanceSettingsRepo _repo;

  Future<void> load() async {
    emit(const AttendanceSettingsState.loading());
    try {
      final settings = await _repo.getSettings();
      emit(
        AttendanceSettingsState(
          status: AttendanceSettingsStatus.ready,
          settings: settings,
        ),
      );
    } catch (e) {
      log('Failed to load attendance settings: $e');
      emit(
        const AttendanceSettingsState(
          status: AttendanceSettingsStatus.failure,
          message:
              "Couldn't load settings. Check your connection and try again.",
        ),
      );
    }
  }

  Future<void> save(AttendanceSettings settings) async {
    emit(state.copyWith(status: AttendanceSettingsStatus.saving));
    try {
      await _repo.saveSettings(settings);
      emit(
        AttendanceSettingsState(
          status: AttendanceSettingsStatus.saved,
          settings: settings,
        ),
      );
    } catch (e) {
      log('Failed to save attendance settings: $e');
      emit(
        state.copyWith(
          status: AttendanceSettingsStatus.failure,
          message: 'Could not save settings. Please try again.',
        ),
      );
    }
  }
}
