import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/features/dashboard_view/manager/cubit/dashboard_cubit.dart';
import 'package:el_karma_ph/features/login_view/manager/login_cubit/cubit/auth_cubit.dart';
import 'package:el_karma_ph/features/no_internet_view/manager/cubit/connection_cubit.dart';
import 'package:el_karma_ph/features/no_internet_view/presentation/view_model/connection_wrapper.dart';
import 'package:el_karma_ph/features/reset_pass_view/manager/cubit/reset_pass_cubit.dart';
import 'package:el_karma_ph/features/settings_view/manager/cubit/app_settings_cubit.dart';
import 'package:el_karma_ph/features/settings_view/manager/cubit/app_settings_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// + imports بتاعة Firebase زي ما عندك

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final appSettingsCubit = await AppSettingsCubit.load();
  runApp(MyApp(appSettingsCubit: appSettingsCubit));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appSettingsCubit});

  final AppSettingsCubit appSettingsCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: appSettingsCubit),
        BlocProvider(create: (_) => ConnectionCubit()),
        BlocProvider.value(value: appSettingsCubit),
        BlocProvider(create: (_) => ConnectionCubit()),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => DashboardCubit()),
        BlocProvider(create: (_) => ResetPassCubit()),
        // أي providers تانية عندك سيبها هنا
      ],
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'El-Karma PH',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryBlue),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: kPrimaryBlue,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => ConnectionWrapper(child: child),
            routerConfig: AppRouter.router,
            // اللي كان ناقص
          );
        },
      ),
    );
  }
}
