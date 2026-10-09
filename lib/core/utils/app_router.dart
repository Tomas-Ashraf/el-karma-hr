// ignore_for_file: unused_field



import 'package:el_karma_ph/features/home_view/presentation/views/home_view.dart';
import 'package:el_karma_ph/features/login_view/presentation/view/login_view.dart';
import 'package:el_karma_ph/features/splash_view/presentation/views/splash_view.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const kHomeView = '/homeView';
  static const kLoginView = '/loginView';




  static final router = GoRouter(
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const SplashView()),
      GoRoute(path: kHomeView,name: kHomeView, builder: (context, state) => const HomeView()),
      GoRoute(path: kLoginView,name: kLoginView, builder: (context, state) => const LoginView()),
     
    ],
  );
}
