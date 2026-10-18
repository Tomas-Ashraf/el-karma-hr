import 'package:el_karma_ph/core/app_colors.dart';
import 'package:el_karma_ph/core/widgets/New%20folder/app_decorations.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.softCard(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: AppColors.text),
          hintText: 'Search',
          hintStyle: TextStyle(color: AppColors.muted),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
