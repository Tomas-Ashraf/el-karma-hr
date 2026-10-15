// ignore_for_file: unused_field

import 'package:el_karma_ph/features/dashboard_view/presentation/view/dashboard_view.dart';
import 'package:el_karma_ph/features/inactive_account_view/presentation/view/inactive_account_view.dart';
import 'package:el_karma_ph/features/login_view/presentation/view/login_view.dart';
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
    ],
  );
}
