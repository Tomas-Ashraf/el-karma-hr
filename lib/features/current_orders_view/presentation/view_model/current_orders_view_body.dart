import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/money_format.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/current_orders_view/models/fake_orders.dart';
import 'package:el_karma_ph/features/current_orders_view/presentation/widgets/empty_state.dart';
import 'package:el_karma_ph/features/current_orders_view/presentation/widgets/order_card.dart';
import 'package:el_karma_ph/features/current_orders_view/presentation/widgets/order_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentOrdersViewBody extends StatelessWidget {
  const CurrentOrdersViewBody({super.key});

  void _snack(ScaffoldMessengerState m, String text, bool ok) {
    m
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
  }

  bool _same(double a, double b) => (a - b).abs() < 0.005;

  String _amountText(double value) =>
      value % 1 == 0 ? '${value.toInt()}' : '$value';

  Future<void> _onSuccess(BuildContext context, OrderItem order) async {
    final cubit = context.read<CurrentOrdersCubit>();
    final messenger = ScaffoldMessenger.of(context);
    String? initial;

    while (true) {
      final value = await showReturnedAmountDialog(context, initial: initial);
      if (value == null || !context.mounted) return;

      if (!_same(value, order.amount)) {
        final proceed = await showAmountMismatchDialog(
          context,
          entered: formatAmount(context, value),
          expected: formatAmount(context, order.amount),
        );
        if (!context.mounted) return;
        if (proceed != true) {
          initial = _amountText(value);
          continue;
        }
      }

      final error = await cubit.markSuccess(order, value);
      if (!context.mounted) return;
      _snack(messenger, context.tr(error ?? 'orders.completed'), error == null);
      return;
    }
  }

  Future<void> _onFailed(BuildContext context, OrderItem order) async {
    final cubit = context.read<CurrentOrdersCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final reason = await showFailureReasonDialog(context);
    if (reason == null || !context.mounted) return;

    final error = await cubit.markFailed(order, reason);
    if (!context.mounted) return;
    _snack(messenger, context.tr(error ?? 'orders.completed'), error == null);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.02,
            ),
            child: _orders.isEmpty
                ? const EmptyState()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                          'orders.count',
                          args: {'count': '${_orders.length}'},
                        ),
                      ],
                    ),
                  );
                }

                if (state.orders.isEmpty) return const EmptyState();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(
                        'orders.count',
                        args: {'count': '${state.orders.length}'},
                      ),
                      style: Styles.textStyle14,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => context
                            .read<CurrentOrdersCubit>()
                            .load(silent: true),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: state.orders.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = state.orders[index];
                            return OrderCard(
                              order: order,
                              busy: state.processingIds.contains(order.id),
                              onSuccess: () => _onSuccess(context, order),
                              onFailed: () => _onFailed(context, order),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
