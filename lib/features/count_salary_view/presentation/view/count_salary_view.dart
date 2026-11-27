import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/features/count_salary_view/manager/cubit/count_salary_cubit.dart';
import 'package:el_karma_ph/features/count_salary_view/manager/cubit/count_salary_state.dart';
import 'package:el_karma_ph/features/count_salary_view/presentation/view_model/count_salary_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CountSalaryView extends StatelessWidget {
  const CountSalaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CountSalaryCubit()..loadEmployees(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            context.tr('salary.title'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              final router = GoRouter.of(context);
              router.canPop()
                  ? router.pop()
                  : router.go(AppRouter.kDashboardView);
            },
          ),
          actions: [
            BlocBuilder<CountSalaryCubit, CountSalaryState>(
              buildWhen: (p, c) => p.selected?.id != c.selected?.id,
              builder: (context, state) {
                final employee = state.selected;
                if (employee == null) return const SizedBox.shrink();
                return IconButton(
                  tooltip: context.tr('salary.history'),
                  icon: const Icon(Icons.history_rounded, color: kPrimaryBlue),
                  onPressed: () => GoRouter.of(context)
                      .pushNamed(AppRouter.kSalaryHistoryView, extra: employee),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: const CountSalaryViewBody(),
      ),
    );
  }
}
