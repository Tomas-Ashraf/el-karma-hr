// ignore_for_file: unused_field

import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/features/login_view/manager/login_cubit/cubit/auth_cubit.dart';
import 'package:el_karma_ph/features/login_view/presentation/widgets/input_field_widget.dart';
import 'package:el_karma_ph/features/login_view/presentation/widgets/login_button.dart';
import 'package:el_karma_ph/features/login_view/presentation/widgets/logo_widget.dart';
import 'package:el_karma_ph/features/login_view/presentation/widgets/welcome_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginViewBody extends StatefulWidget {
  const LoginViewBody({super.key});

  @override
  State<LoginViewBody> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginViewBody> {
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 440.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccessState) {
            GoRouter.of(context).pushReplacementNamed(AppRouter.kDashboardView);
          } else if (state is AuthFailureState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.06,
                  vertical: screenSize.height * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenSize.height * 0.02),
                    ElKarmaLogoWidget(height: 100, width: 100),
                    SizedBox(height: screenSize.height * 0.035),
                    WelcomeWidget(),
                    SizedBox(height: screenSize.height * 0.03),
                    InputFieldWidget(
                      label: 'Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        _emailController = value as TextEditingController;
                      },
                      onSubmitted: (value) {},
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    InputFieldWidget(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: (value) {
                        _passwordController = value as TextEditingController;
                      },
                      onSubmitted: (value) {},
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          GoRouter.of(context)
                              .pushNamed(AppRouter.kResetPassView);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forgot Password ?',
                          style: TextStyle(
                            color: kPrimaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.10),
                    LoginButton(
                      emailController: _emailController,
                      passwordController: _passwordController,
                    ),
                    SizedBox(height: screenSize.height * 0.06),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
