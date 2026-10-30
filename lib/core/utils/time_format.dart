import 'package:flutter/material.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';

String formatTime(BuildContext context, DateTime time) =>
    TimeOfDay.fromDateTime(time).format(context);

String formatDateTime(BuildContext context, DateTime time) {
  final date = MaterialLocalizations.of(context).formatShortMonthDay(time);
  return '${formatTime(context, time)} · $date';
}

String formatShortDate(BuildContext context, DateTime date) =>
    MaterialLocalizations.of(context).formatShortMonthDay(date);

String formatMediumDate(BuildContext context, DateTime date) =>
    MaterialLocalizations.of(context).formatMediumDate(date);
String formatMinutes(AppLocalizations l10n, int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return l10n.translate('duration.minutes', args: {'m': '$m'});
  if (m == 0) return l10n.translate('duration.hours', args: {'h': '$h'});
  return l10n.translate('duration.hours_minutes', args: {'h': '$h', 'm': '$m'});
}

String formatDuration(BuildContext context, int minutes) =>
    formatMinutes(AppLocalizations.of(context), minutes);
