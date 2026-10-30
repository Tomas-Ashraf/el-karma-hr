import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/features/record_details_view/presentation/view_model/record_details_view_body.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecordDetailsView extends StatelessWidget {
  const RecordDetailsView({super.key, required this.record});

  final RecordPreview record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          context.tr('records.details_title'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            final router = GoRouter.of(context);
            router.canPop()
                ? router.pop()
                : router.go(AppRouter.kRecordsView);
          },
        ),
      ),
      body: RecordDetailsViewBody(record: record),
    );
  }
}
