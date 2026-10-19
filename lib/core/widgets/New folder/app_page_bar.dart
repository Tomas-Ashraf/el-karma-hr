import 'package:el_karma_ph/core/app_colors.dart';
import 'package:flutter/material.dart';

class AppPageBar extends StatelessWidget implements PreferredSizeWidget {
  const AppPageBar({super.key, required this.title, this.showBack = true});

  final String title;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      automaticallyImplyLeading: false,
      leadingWidth: 56,
      titleSpacing: showBack ? 12 : 20,
      leading: showBack ? const _BackButton() : null,
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Material(
        color: AppColors.blueSoft,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: AppColors.blue,
          ),
        ),
      ),
    );
  }
}
