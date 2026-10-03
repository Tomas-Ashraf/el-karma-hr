// ignore_for_file: unused_field



import 'package:el_karma_ph/features/home_view/presentation/views/home_view.dart';
import 'package:el_karma_ph/features/splash_view/presentation/views/splash_view.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const kHomeView = '/homeView';
  static const kBookDetails = '/bookDetailsView';
  static const kSearchView = '/searchView';

  static final router = GoRouter(
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const SplashView()),
      GoRoute(path: kHomeView, builder: (context, state) => const HomeView()),
      
    ],
  );
}
