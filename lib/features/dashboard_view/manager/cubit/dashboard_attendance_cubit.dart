import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/dashboard_view/manager/logic/attendance_calculator.dart';
import 'package:el_karma_ph/features/dashboard_view/models/dashboard_models.dart';
import 'package:el_karma_ph/features/dashboard_view/repos/dashboard_repo.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/settings_view/models/attendance_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'dashboard_attendance_state.dart';

class DashboardAttendanceCubit extends Cubit<DashboardAttendanceState> {
  DashboardAttendanceCubit({DashboardRepo? repo})
    : _repo = repo ?? DashboardRepo(),
      super(DashboardAttendanceLoading());

  final DashboardRepo _repo;

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(DashboardAttendanceLoading());
    try {
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, now.day - 1);
      final to = DateTime(now.year, now.month, now.day + 1);

      final first = await Future.wait<Object>([
        _repo.getEmployees(),
        _repo.getSettings(),
      ]);
      final employees = first[0] as List<EmployeeModel>;
      final settings = first[1] as AttendanceSettings;

      final punches = await _repo.getPunches(
        deviceIds: employees
            .where((e) => e.isActive && e.shifts.isNotEmpty)
            .map((e) => e.deviceId),
        from: from,
        to: to,
      );

      final data = AttendanceCalculator.calculate(
        employees: employees,
        settings: settings,
        punchesByDevice: punches,
        now: now,
      );
      if (!isClosed) emit(DashboardAttendanceSuccess(data));
    } on FirebaseException catch (e) {
      log('Failed to load dashboard: ${e.code}');
      if (isClosed) return;
      emit(
        DashboardAttendanceFailure(
          e.code == 'unavailable'
              ? 'error.no_internet'
              : 'dashboard.load_failed',
        ),
      );
    } catch (e) {
      log('Unexpected error loading dashboard: $e');
      if (!isClosed) emit(DashboardAttendanceFailure('dashboard.load_failed'));
    }
  }
}
