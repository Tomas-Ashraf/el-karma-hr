import 'package:el_karma_ph/bloc_observer.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/features/dashboard_view/manager/cubit/dashboard_cubit.dart';
import 'package:el_karma_ph/features/login_view/manager/login_cubit/cubit/auth_cubit.dart';
import 'package:el_karma_ph/features/reset_pass_view/manager/cubit/reset_pass_cubit.dart';
import 'package:el_karma_ph/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    final auth = FirebaseAuth.instance;

    debugPrint('Firebase App: ${auth.app.name}');
    debugPrint('Current User: ${auth.currentUser?.uid}');

    await auth.signOut();

    debugPrint('Firebase Auth channel is working');
  } catch (e, stackTrace) {
    debugPrint('Firebase Auth test failed: $e');
    debugPrint('$stackTrace');
  }
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<ResetPassCubit>(create: (context) => ResetPassCubit()),
        BlocProvider<DashboardCubit>(
          create: (context) => DashboardCubit()..getUserData(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'El-Karma PH',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
