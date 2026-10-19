import 'package:el_karma_ph/core/app_colors.dart';
import 'package:el_karma_ph/core/utils/employee/employee.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/New%20folder/soft_button.dart';
import 'package:el_karma_ph/core/widgets/New%20folder/user_avatar.dart';
import 'package:flutter/material.dart';

class EmployeeTile extends StatelessWidget {
  const EmployeeTile({
    super.key,
    required this.employee,
    required this.onTap,
    required this.onDelete,
  });

  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            const UserAvatar(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(employee.name, style: Styles.textStyle14),
                  const SizedBox(height: 2),
                  Text(
                    employee.job,
                    overflow: TextOverflow.ellipsis,
                    style: Styles.textStyle12,
                  ),
                ],
              ),
            ),
            SoftButton(
              label: 'Delete',
              icon: Icons.delete_outline,
              background: AppColors.redSoft,
              foreground: AppColors.red,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
