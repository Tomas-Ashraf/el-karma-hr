import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/features/settings_view/manager/cubit/app_settings_cubit.dart';
import 'package:el_karma_ph/features/settings_view/manager/cubit/app_settings_state.dart';
import 'package:el_karma_ph/features/settings_view/presentation/widgets/settings_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, state) {
        final cubit = context.read<AppSettingsCubit>();

        return SettingsSectionCard(
          title: context.tr('settings.app_section'),
          child: Column(
            children: [
              SettingsSwitchTile(
                icon: state.isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                title: context.tr('settings.dark_mode'),
                subtitle: state.isDarkMode
                    ? context.tr('settings.dark_theme')
                    : context.tr('settings.light_theme'),
                value: state.isDarkMode,
                onChanged: cubit.setDarkMode,
              ),
              const Divider(height: 28),
              SettingsSwitchTile(
                icon: Icons.language_rounded,
                title: state.isArabic ? 'اللغة' : 'Language',
                subtitle: state.isArabic ? 'العربية' : 'English',
                value: state.isArabic,
                onChanged: cubit.setArabic,
              ),
            ],
          ),
        );
      },
    );
  }
}
