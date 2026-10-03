import 'package:el_karma_ph/features/splash_view/presentation/view_models/splash_view_body.dart';
import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Padding(
      padding: EdgeInsets.all(10.0),
      child: SplashViewBody(),
    ));
  }
}
