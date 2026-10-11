import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/login_view/presentation/widgets/input_field_widget.dart';
import 'package:el_karma_ph/features/reset_pass_view/manager/cubit/reset_pass_cubit.dart';
import 'package:el_karma_ph/features/reset_pass_view/presentation/widgets/forgot_password_illustration.dart';
import 'package:el_karma_ph/features/reset_pass_view/presentation/widgets/reset_pass_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordViewBody extends StatefulWidget {
  const ForgotPasswordViewBody({super.key});

  @override
  State<ForgotPasswordViewBody> createState() => _ForgotPasswordViewBodyState();
}

class _ForgotPasswordViewBodyState extends State<ForgotPasswordViewBody> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 440.0;
    final illustrationSize = (screenSize.height * 0.28).clamp(140.0, 260.0);

    return BlocListener<ResetPassCubit, ResetPassState>(
      listener: (context, state) {
        if (state is ResetPassSuccessState) {
          GoRouter.of(context).pushReplacementNamed(
            AppRouter.kResetEmailSentView,
            extra: _emailController.text.trim(),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset email sent successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ResetPassFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: SafeArea(
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
                    onSubmitted: (_) => context
                        .read<ResetPassCubit>()
                        .sendPasswordResetEmail(email: _emailController.text),
                    onChanged: (String p1) {},
                  ),
                  SizedBox(height: screenSize.height * 0.10),
                  ResetPassButton(emailController: _emailController),
                  SizedBox(height: screenSize.height * 0.06),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
