import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:flutter/material.dart';

const kJobKeys = ['doctor', 'assistant', 'cashier', 'delivery'];

String? normalizeJob(String raw) {
  final value = raw.trim().toLowerCase();
  return kJobKeys.contains(value) ? value : null;
}

Map<String, String> jobOptions(BuildContext context) => {
  for (final key in kJobKeys) key: context.tr('job.$key'),
};

String jobLabel(BuildContext context, String raw) =>
    jobLabelOf(AppLocalizations.of(context), raw);

String jobLabelOf(AppLocalizations l10n, String raw) {
  final key = normalizeJob(raw);
  return key == null ? raw : l10n.translate('job.$key');
}
