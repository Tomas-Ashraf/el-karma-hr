part of 'dashboard_attendance_cubit.dart';

sealed class DashboardAttendanceState {}

final class DashboardAttendanceLoading extends DashboardAttendanceState {}

final class DashboardAttendanceSuccess extends DashboardAttendanceState {
  DashboardAttendanceSuccess(this.data);

  final DashboardData data;
}

final class DashboardAttendanceFailure extends DashboardAttendanceState {
  DashboardAttendanceFailure(this.errorMessage);

  final String errorMessage;
}
