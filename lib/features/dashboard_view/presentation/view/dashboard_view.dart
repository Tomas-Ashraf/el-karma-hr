import 'package:el_karma_ph/features/dashboard_view/presentation/app_drawer/view/app_drawer.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/view_model/dashboard_view_body.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      drawer: AppDrawer(),
      body: HomeViewBody(),
    );
  }
}
