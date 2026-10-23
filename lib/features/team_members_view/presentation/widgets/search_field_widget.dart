import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class SearchFieldWidget extends StatelessWidget {
  const SearchFieldWidget({
    super.key,
    required this.onChanged,
    required this.hintText,
  });

  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: border(colors.outlineVariant),
        enabledBorder: border(colors.outlineVariant),
        focusedBorder: border(kPrimaryBlue, 1.5),
      ),
    );
  }
}
