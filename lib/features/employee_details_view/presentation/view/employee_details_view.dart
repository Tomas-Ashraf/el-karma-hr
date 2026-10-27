import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/features/employee_details_view/manager/cubit/employee_details_cubit.dart';
import 'package:el_karma_ph/features/employee_details_view/presentation/view_model/employee_details_view_body.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EmployeeDetailsView extends StatelessWidget {
  const EmployeeDetailsView({super.key, required this.employee});

  final EmployeeModel employee;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmployeeDetailsCubit(employee),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            context.tr('employee_details.title'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              final router = GoRouter.of(context);
              router.canPop()
                  ? router.pop()
                  : router.go(AppRouter.kEmployeeListView);
            },
          ),
        ),
        body: const EmployeeDetailsViewBody(),
      ),
    );
  }
}
