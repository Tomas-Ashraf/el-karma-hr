import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:flutter/material.dart';

String formatAmountOf(AppLocalizations l10n, double value) {
  final text = value % 1 == 0
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
  return '$text ${l10n.translate('common.egp')}';
}

String formatAmount(BuildContext context, double value) =>
    formatAmountOf(AppLocalizations.of(context), value);
