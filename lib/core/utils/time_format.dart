import 'package:flutter/material.dart';

String formatTime(BuildContext context, DateTime time) =>
    TimeOfDay.fromDateTime(time).format(context);
