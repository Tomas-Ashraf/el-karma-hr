import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/dashboard_view/presentation/app_drawer/models/drawer_entry_model.dart';
import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {
  const DrawerTile({super.key, required this.entry});

  final DrawerEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(entry.icon, size: 20, color: kPrimaryBlue),
        ),
        title: Text(
          entry.label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
        onTap: () {
          Navigator.of(context).pop();
          entry.onTap();
        },
      ),
    );
  }
}
