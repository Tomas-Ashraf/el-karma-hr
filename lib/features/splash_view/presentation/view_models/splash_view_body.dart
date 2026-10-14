// ignore_for_file: use_build_context_synchronously

import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/features/login_view/presentation/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> slidingAnimation;

  @override
  void initState() {
    super.initState();
    initSlidingAnimation();
    navigateToHome();
  }

  Future<void> navigateToHome() async {
    final prefs = await SharedPreferences.getInstance();

    final routeFuture = _resolveNextRoute(prefs);
    await Future.delayed(const Duration(seconds: 1));
    final route = await routeFuture;

    if (!mounted) return;
    GoRouter.of(context).pushReplacementNamed(route);
  }

  Future<String> _resolveNextRoute(SharedPreferences prefs) async {
    final isLogged = prefs.getBool('loggedIn') ?? false;
    final email = prefs.getString('userEmail');
    log('isLogged: $isLogged');

    if (!isLogged || email == null || email.isEmpty) {
      return AppRouter.kLoginView;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));

      if (snapshot.docs.isEmpty) {
        await prefs.setBool('loggedIn', false);
        return AppRouter.kLoginView;
      }

      final status = (snapshot.docs.first.data()['status'] as String?)
          ?.trim()
          .toLowerCase();

      if (status == 'inactive') return AppRouter.kInactiveAccountView;
      return AppRouter.kDashboardView;
    } catch (e) {
      log('Splash status check failed: $e');
      return AppRouter.kDashboardView;
    }
  }
  // Future<void> navigateToHome() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   bool? isLogged = prefs.getBool('loggedIn');
  //   log('isLogged: $isLogged');
  //   Future.delayed(const Duration(seconds: 1), () async {
  //     final db = FirebaseFirestore.instance;
  //     final snapshot = await db
  //         .collection(kUsersCollection)
  //         .where('email', isEqualTo: prefs.getString('userEmail'))
  //         .get();
  //     final status = snapshot.docs[0]['status'];
  //     if (isLogged == true && status == 'active') {
  //       GoRouter.of(context).pushReplacementNamed(AppRouter.kDashboardView);
  //     } else if (isLogged == true && status == 'inactive') {
  //       GoRouter.of(context)
  //           .pushReplacementNamed(AppRouter.kInactiveAccountView);
  //     } else if (isLogged == false || isLogged == null) {
  //       GoRouter.of(context).pushReplacementNamed(AppRouter.kLoginView);
  //     }
  //   });
  // }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 440.0;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxContentWidth),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElKarmaLogoWidget(
            height: screenSize.height * 0.50,
            width: screenSize.width * 0.50,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void initSlidingAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    slidingAnimation = Tween<Offset>(
      begin: const Offset(0, 20),
      end: const Offset(0, 0),
    ).animate(animationController);
    animationController.forward();
  }
}
