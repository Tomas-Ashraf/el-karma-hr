import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/reset_email_sent_view/presentation/widgets/email_sent_illustration.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResetEmailSentViewBody extends StatelessWidget {
  const ResetEmailSentViewBody({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 440.0;
    final illustrationSize = (screenSize.height * 0.28)
        .clamp(140.0, 260.0)
        .toDouble();
    final emailText = email.isEmpty ? 'your email' : email;

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
                        EmailSentIllustration(size: illustrationSize),
                        SizedBox(height: screenSize.height * 0.04),
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Check your email '),
                              TextSpan(
                                text: '📬',
                                style: TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                          style: Styles.textStyle26B,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text.rich(
                          TextSpan(
                            style: Styles.textStyle14,
                            children: [
                              const TextSpan(text: 'If '),
                              TextSpan(
                                text: emailText,
                                style: const TextStyle(
                                  color: kPrimaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    ' is registered, we sent a password '
                                    'reset link to it. Open the link, set a '
                                    'new password, then come back and log in.',
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Didn't get it? Check your spam folder.",
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
