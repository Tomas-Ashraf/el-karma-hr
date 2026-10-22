import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/features/team/presentation/view/team_list_page.dart';
import 'package:flutter/material.dart';

class TeamMembers extends StatelessWidget {
  const TeamMembers({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Team Members',
      theme: AppTheme.light,
      home: const TeamListPage(),
    );
  }
}
