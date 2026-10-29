import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/attendance_view.dart/manager/cubit/attendance_report_state.dart';
import 'package:el_karma_ph/features/attendance_view.dart/models/attendance_record.dart';
import 'package:el_karma_ph/features/attendance_view.dart/repos/records_repo.dart';

import 'package:el_karma_ph/features/dashboard_view/manager/logic/attendance_calculator.dart';
import 'package:el_karma_ph/features/dashboard_view/repos/dashboard_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceReportCubit extends Cubit<AttendanceReportState> {
  AttendanceReportCubit({DashboardRepo? repo, RecordsRepo? recordsRepo})
    : _repo = repo ?? DashboardRepo(),
      _recordsRepo = recordsRepo ?? RecordsRepo(),
      super(
        const AttendanceReportState(
          status: AttendanceReportStatus.loadingEmployees,
        ),
      );

  final DashboardRepo _repo;
  final RecordsRepo _recordsRepo;

  Future<void> loadEmployees() async {
    emit(state.copyWith(status: AttendanceReportStatus.loadingEmployees));
    try {
      final employees = await _repo.getEmployees();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AttendanceReportStatus.ready,
          employees: employees,
        ),
      );
    } on FirebaseException catch (e) {
      log('Failed to load employees: ${e.code}');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AttendanceReportStatus.failure,
          message: e.code == 'unavailable'
              ? 'error.no_internet'
              : 'employees.load_failed',
        ),
      );
    } catch (e) {
      log('Unexpected error loading employees: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AttendanceReportStatus.failure,
          message: 'employees.load_failed',
        ),
      );
    }
  }

  Future<void> calculate(AttendanceFilter filter) async {
    emit(
      state.copyWith(
        status: AttendanceReportStatus.calculating,
        filter: filter,
        saveStatus: RecordSaveStatus.idle,
      ),
    );
    try {
      final employee = filter.employee;
      final settings = await _repo.getSettings();

      final punches = await _repo.getPunches(
        deviceIds: [employee.deviceId],
        from: DateTime(
          filter.from.year,
          filter.from.month,
          filter.from.day - 1,
        ),
        to: DateTime(filter.to.year, filter.to.month, filter.to.day + 2),
      );

      final entries = AttendanceCalculator.calculateRange(
        employee: employee,
        punches: punches[employee.deviceId] ?? const [],
        settings: settings,
        from: filter.from,
        to: filter.to,
        now: DateTime.now(),
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AttendanceReportStatus.success,
          entries: entries,
          settings: settings,
        ),
      );
    } on FirebaseException catch (e) {
      log('Failed to calculate attendance: ${e.code}');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AttendanceReportStatus.failure,
          message: e.code == 'unavailable'
              ? 'error.no_internet'
              : 'attendance.load_failed',
        ),
      );
    } catch (e) {
      log('Unexpected error calculating attendance: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AttendanceReportStatus.failure,
          message: 'attendance.load_failed',
        ),
      );
    }
  }

  Future<void> saveRecord() async {
    final filter = state.filter;
    final settings = state.settings;
    if (state.status != AttendanceReportStatus.success ||
        filter == null ||
        settings == null ||
        state.entries.isEmpty ||
        state.saveStatus == RecordSaveStatus.saving) {
      return;
    }

    emit(state.copyWith(saveStatus: RecordSaveStatus.saving));
    try {
      await _recordsRepo.saveRecord(
        AttendanceRecord(
          employee: filter.employee,
          from: filter.from,
          to: filter.to,
          entries: state.entries,
          settings: settings,
        ),
      );
      if (isClosed) return;
      emit(state.copyWith(saveStatus: RecordSaveStatus.saved));
    } on FirebaseException catch (e) {
      log('Failed to save record: ${e.code}');
      if (isClosed) return;
      emit(
        state.copyWith(
          saveStatus: RecordSaveStatus.failed,
          message: e.code == 'unavailable'
              ? 'error.no_internet'
              : 'attendance.record_failed',
        ),
      );
    } catch (e) {
      log('Unexpected error saving record: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          saveStatus: RecordSaveStatus.failed,
          message: 'attendance.record_failed',
        ),
      );
    }
  }
}
