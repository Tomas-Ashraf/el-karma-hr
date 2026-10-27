// ignore_for_file: use_build_context_synchronously

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
  Future<void> _openDetails(
    BuildContext context,
    EmployeeModel employee,
  ) async {
    final cubit = context.read<EmployeesCubit>();
    await GoRouter.of(context)
        .pushNamed(AppRouter.kEmployeeDetailsView, extra: employee);
    if (!mounted) return;
    cubit.fetchEmployees(silent: true);
  }

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

  Future<void> _confirmDelete(
    BuildContext context,
    EmployeeModel employee,
  ) async {
    final cubit = context.read<EmployeesCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(name: employee.name),
    );
    if (confirmed != true) return;

    final error = await cubit.deleteEmployee(employee.id);
    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(context.tr(error ?? 'employees.deleted')),
        backgroundColor: error == null ? Colors.green : Colors.red,
      ),
    );
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
                  onPressed: () async {
                    final added = await GoRouter.of(context)
                        .pushNamed<bool>(AppRouter.kAddEmployeeView);
                    if (added == true && context.mounted) {
                      context.read<EmployeesCubit>().fetchEmployees(
                        silent: true,
                      );
                    }
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
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      return EmployeeTileWidget(
                        employee: employee,
                        onTap: () => _openDetails(context, employee),
                        onDelete: () => _confirmDelete(context, employee),
                      );
                    },
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

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        context.tr('employees.delete_title'),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Text(
        context.tr('employees.delete_message', args: {'name': name}),
        style: Styles.textStyle14,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.tr('common.cancel')),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(context.tr('common.delete')),
        ),
      ],
    );
  }
}
