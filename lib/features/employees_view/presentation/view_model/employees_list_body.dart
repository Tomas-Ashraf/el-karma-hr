import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/employees_view/manager/cubit/employees_cubit.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/employees_view/presentation/widgets/employee_tile_widget.dart';
import 'package:el_karma_ph/features/employees_view/presentation/widgets/search_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EmployeesListBody extends StatefulWidget {
  const EmployeesListBody({super.key});

  @override
  State<EmployeesListBody> createState() => _EmployeesListBodyState();
}

class _EmployeesListBodyState extends State<EmployeesListBody> {
  String _query = '';

  List<EmployeeModel> _filter(List<EmployeeModel> all) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return all;
    return all
        .where(
          (e) =>
              e.name.toLowerCase().contains(query) ||
              e.job.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 700.0;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchFieldWidget(
                  hintText: context.tr('employees.search_hint'),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<EmployeesCubit, EmployeesState>(
                    builder: (context, state) {
                      if (state is EmployeesSuccess) {
                        return _buildList(context, _filter(state.employees));
                      }
                      if (state is EmployeesFailure) {
                        return _ErrorState(
                          message: context.tr(state.errorMessage),
                          onRetry: () =>
                              context.read<EmployeesCubit>().fetchEmployees(),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ButtonWidget(
                  width: double.infinity,
                  height: 52,
                  onPressed: () {
                    GoRouter.of(context).pushNamed(AppRouter.kAddEmployeeView);
                  },
                  backgroundColor: kPrimaryBlue,
                  foregroundColor: Colors.white,
                  text: Text(
                    context.tr('employees.add'),
                    style: Styles.textStyle16,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<EmployeeModel> employees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('employees.count', args: {'count': '${employees.length}'}),
          style: Styles.textStyle14,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: employees.isEmpty
              ? const _EmptyState()
              : RefreshIndicator(
                  onRefresh: () => context
                      .read<EmployeesCubit>()
                      .fetchEmployees(silent: true),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: employees.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => EmployeeTileWidget(
                      employee: employees[index],
                      onTap: () {},
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: kPrimaryBlue.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              size: 34,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(context.tr('employees.empty'), style: Styles.textStyle14),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: Styles.textStyle14, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(context.tr('common.retry')),
          ),
        ],
      ),
    );
  }
}
