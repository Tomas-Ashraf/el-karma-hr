// ignore_for_file: unused_field

import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/login_view/presentation/widgets/input_field_widget.dart';
import 'package:el_karma_ph/features/login_view/presentation/widgets/logo_widget.dart';
import 'package:el_karma_ph/features/login_view/presentation/widgets/welcome_widget.dart';
import 'package:flutter/material.dart';

class LoginViewBody extends StatefulWidget {
  const LoginViewBody({super.key});

  @override
  State<LoginViewBody> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginViewBody> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
      body: SafeArea(
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
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  InputFieldWidget(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
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
                  SizedBox(height: screenSize.height * 0.025),
                  ButtonWidget(
                    width: double.infinity,
                    height: 52,
                    onPressed: () {},
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: Colors.white,
                    text: const Text('Login', style: Styles.textStyle16),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
