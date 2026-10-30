// ignore_for_file: unused_field

import 'package:el_karma_ph/features/add_employee_view/presentation/view/add_employee_view.dart';
import 'package:el_karma_ph/features/attendance_view.dart/presentation/view/attendance_view.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/view/dashboard_view.dart';
import 'package:el_karma_ph/features/employee_details_view/presentation/view/employee_details_view.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/employees_view/presentation/view/employees_list_view.dart';
import 'package:el_karma_ph/features/inactive_account_view/presentation/view/inactive_account_view.dart';
import 'package:el_karma_ph/features/login_view/presentation/view/login_view.dart';
import 'package:el_karma_ph/features/record_details_view/presentation/view/record_details_view.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';
import 'package:el_karma_ph/features/records_view/presentation/view/records_view.dart';
import 'package:el_karma_ph/features/reset_email_sent_view/presentation/view/reset_email_sent_view.dart';
import 'package:el_karma_ph/features/reset_pass_view/presentation/view/reset_pass_view.dart';
import 'package:el_karma_ph/features/settings_view/presentation/view/settings_view.dart';
import 'package:el_karma_ph/features/splash_view/presentation/views/splash_view.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const kDashboardView = '/dashboardView';
  static const kLoginView = '/loginView';
  static const kResetPassView = '/resetPassView';
  static const kResetEmailSentView = '/resetEmailSentView';
  static const kInactiveAccountView = '/inactiveAccountView';
  static const kSettingsView = '/settingsView';
  static const kEmployeeListView = '/employeeListView';
  static const kAddEmployeeView = '/addEmployeeView';
  static const kEmployeeDetailsView = '/employeeDetailsView';
  static const kAttendanceView = '/attendanceView';
  static const kRecordsView = '/recordsView';
  static const kRecordDetailsView = '/recordDetailsView';

  static final router = GoRouter(
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const SplashView()),
      GoRoute(
        path: kDashboardView,
        name: kDashboardView,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: kLoginView,
        name: kLoginView,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: kResetPassView,
        name: kResetPassView,
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: kResetEmailSentView,
        name: kResetEmailSentView,
        builder: (context, state) =>
            ResetEmailSentView(email: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: kInactiveAccountView,
        name: kInactiveAccountView,
        builder: (context, state) => InactiveAccountView(),
      ),
      GoRoute(
        path: kSettingsView,
        name: kSettingsView,
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: kEmployeeListView,
        name: kEmployeeListView,
        builder: (context, state) => const EmployeesListView(),
      ),
      GoRoute(
        path: kAddEmployeeView,
        name: kAddEmployeeView,
        builder: (context, state) => const AddEmployeeView(),
      ),
      GoRoute(
        path: kEmployeeDetailsView,
        name: kEmployeeDetailsView,
        redirect: (context, state) =>
            state.extra is EmployeeModel ? null : kEmployeeListView,
        builder: (context, state) =>
            EmployeeDetailsView(employee: state.extra as EmployeeModel),
      ),
      GoRoute(
        path: kAttendanceView,
        name: kAttendanceView,
        builder: (context, state) => const AttendanceView(),
      ),
      GoRoute(
        path: kRecordsView,
        name: kRecordsView,
        builder: (context, state) => const RecordsView(),
      ),
      GoRoute(
        path: kRecordDetailsView,
        name: kRecordDetailsView,
        redirect: (context, state) =>
            state.extra is RecordPreview ? null : kRecordsView,
        builder: (context, state) =>
            RecordDetailsView(record: state.extra as RecordPreview),
      ),
    ],
  );
}
