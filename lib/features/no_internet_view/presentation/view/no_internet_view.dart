import 'package:el_karma_ph/features/no_internet_view/presentation/view_model/no_internet_view_body.dart';
import 'package:flutter/material.dart';

class NoInternetView extends StatelessWidget {
  const NoInternetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: NoInternetViewBody()));
  }
}
