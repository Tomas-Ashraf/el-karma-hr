import 'package:el_karma_ph/features/reset_email_sent_view/presentation/view_model/reset_email_sent_view_body.dart';
import 'package:flutter/material.dart';

class ResetEmailSentView extends StatelessWidget {
  const ResetEmailSentView({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResetEmailSentViewBody(email: email),
    );
  }
}
