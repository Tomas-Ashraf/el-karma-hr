import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';
import 'package:el_karma_ph/features/count_salary_view/presentation/view_model/salary_sheet_view_body.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SalarySheetView extends StatelessWidget {
  const SalarySheetView({super.key, required this.sheet});

  final SalarySheet sheet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          context.tr('salary.sheet_title'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            final router = GoRouter.of(context);
            router.canPop()
                ? router.pop()
                : router.go(AppRouter.kCountSalaryView);
          },
        ),
      ),
      body: SalarySheetViewBody(sheet: sheet),
    );
  }
}
