import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/inactive_account_view/presentation/widgets/inactive_illustration.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InactiveAccountViewBody extends StatelessWidget {
  const InactiveAccountViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 440.0;
    final illustrationSize = (screenSize.height * 0.28)
        .clamp(140.0, 260.0)
        .toDouble();

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.06,
                      vertical: screenSize.height * 0.03,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InactiveIllustrationWidget(size: illustrationSize),
                        SizedBox(height: screenSize.height * 0.04),
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Account inactive '),
                              TextSpan(
                                text: '🚫',
                                style: TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                          style: Styles.textStyle26B,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your account is currently inactive. Please contact '
                          'your administrator to get it reactivated.',
                          style: Styles.textStyle14,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenSize.height * 0.05),
                        ButtonWidget(
                          width: double.infinity,
                          height: 52,
                          onPressed: () =>
                              GoRouter.of(context)
                                  .goNamed(AppRouter.kLoginView),
                          backgroundColor: kPrimaryBlue,
                          foregroundColor: Colors.white,
                          text: const Text(
                            'Back to Login',
                            style: Styles.textStyle16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
