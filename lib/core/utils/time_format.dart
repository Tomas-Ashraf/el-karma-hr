import 'package:flutter/material.dart';

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
