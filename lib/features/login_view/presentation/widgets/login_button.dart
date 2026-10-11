import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/login_view/manager/login_cubit/cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key, required this.email, required this.password});
  final String email;
  final String password;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final isLoading = state is LoginLoadingState;
        return ButtonWidget(
          width: double.infinity,
          height: 52,
          onPressed: () {
            if (isLoading) return;
            BlocProvider.of<LoginCubit>(context)
                .loginUser(email: email, password: password);
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
              : const Text('Login', style: Styles.textStyle16),
        );
      },
    );
  }
}
