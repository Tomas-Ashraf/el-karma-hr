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

const _dartWeekdayKeys = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

String weekdayKey(DateTime date) => _dartWeekdayKeys[date.weekday - 1];
