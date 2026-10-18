import 'package:el_karma_ph/core/utils/employee/employee.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/New%20folder/user_avatar.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({required this.employee});
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          const UserAvatar(size: 76),
          const SizedBox(height: 8),
          Text(employee.name, style: Styles.textStyle16),
          Text(employee.job, style: Styles.textStyle12),
        ],
      ),
    );
  }
}
