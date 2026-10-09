// ignore_for_file: use_build_context_synchronously

import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/features/login_view/presentation/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  void navigateToHome() {
    Future.delayed(const Duration(seconds: 1), () {
      GoRouter.of(context).pushReplacementNamed(AppRouter.kLoginView);
    });
  }

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
            height: screenSize.height * 0.53,
            width: screenSize.width * 0.53,
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
