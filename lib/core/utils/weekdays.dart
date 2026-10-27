import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:flutter/material.dart';

const kWeekdays = [
  'saturday',
  'sunday',
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
];

Map<String, String> weekdayOptions(BuildContext context) => {
  for (final day in kWeekdays) day: context.tr('day.$day'),
};
