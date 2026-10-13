import 'package:el_karma_ph/features/inactive_account_view/presentation/view_model/inactive_account_view_body.dart';
import 'package:flutter/material.dart';

class InactiveAccountView extends StatelessWidget {
  const InactiveAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: InactiveAccountViewBody(),
    );
  }
}
