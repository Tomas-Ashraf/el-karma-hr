import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/login_view/presentation/widgets/input_field_widget.dart';
import 'package:el_karma_ph/features/reset_pass_view/presentation/widgets/forgot_password_illustration.dart';
import 'package:el_karma_ph/features/reset_pass_view/presentation/widgets/reset_pass_button.dart';
import 'package:flutter/material.dart';

class ForgotPasswordViewBody extends StatelessWidget {
  ForgotPasswordViewBody({super.key});

  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 440.0;
    final illustrationSize = (screenSize.height * 0.28).clamp(140.0, 260.0);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.06,
              vertical: screenSize.height * 0.01,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Forgot password '),
                      TextSpan(text: '🤔', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  style: Styles.textStyle26B,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter the email address linked to your account and we'll "
                  'send you a link to reset your password.',
                  style: Styles.textStyle14,
                ),
                SizedBox(height: screenSize.height * 0.03),
                Center(
                  child: ForgotPasswordIllustration(size: illustrationSize),
                ),
                SizedBox(height: screenSize.height * 0.04),
                InputFieldWidget(
                  label: 'Email Address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) {},
                  onSubmitted: (String value) {},
                ),
                SizedBox(height: screenSize.height * 0.16),
                ResetPassButton(email: _emailController.text.trim()),
                SizedBox(height: screenSize.height * 0.06),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
