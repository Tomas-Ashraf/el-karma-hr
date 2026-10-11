import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/features/reset_pass_view/presentation/view_model/reset_pass_view_body.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            final router = GoRouter.of(context);
            router.canPop() ? router.pop() : router.go(AppRouter.kLoginView);
          },
        ),
      ),
      body: ForgotPasswordViewBody(),
    );
  }
}
