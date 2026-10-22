import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/login_view/manager/login_cubit/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.lable,
  });
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Text lable;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;
        return ButtonWidget(
          width: double.infinity,
          height: 52,
          onPressed: () async {
            if (isLoading) return;

            final authCubit = context.read<AuthCubit>();
            final router = GoRouter.of(context);

            final isActive = await authCubit.checkAccountStatus(
              email: emailController.text.trim(),
            );

            if (!context.mounted) return;

            if (!isActive) {
              if (authCubit.state is AuthInitial) {
                router.push(AppRouter.kInactiveAccountView);
              }
              return;
            }

            await authCubit.loginUser(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );
          },
          backgroundColor: kPrimaryBlue,
          foregroundColor: Colors.white,
          text: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : lable,
        );
      },
    );
  }
}
