import 'package:el_karma_ph/features/settings_view/presentation/widgets/app_settings_section.dart';
import 'package:el_karma_ph/features/settings_view/presentation/widgets/attend_settings_section.dart';
import 'package:flutter/material.dart';

class SettingsViewBody extends StatelessWidget {
  const SettingsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 600.0;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.02,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSettingsSection(),
                SizedBox(height: 24),
                AttendanceSettingsSection(),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
