import 'package:el_karma_ph/features/login_view/presentation/view_model/login_view_body.dart';
import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LoginViewBody(),);
  }
}