import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/current_orders_view/manager/cubit/current_orders_cubit.dart';
import 'package:el_karma_ph/features/current_orders_view/manager/cubit/current_orders_state.dart';
import 'package:el_karma_ph/features/current_orders_view/models/order_item.dart';
import 'package:el_karma_ph/features/current_orders_view/presentation/widgets/empty_state.dart';
import 'package:el_karma_ph/features/current_orders_view/presentation/widgets/order_card.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustment_card.dart'
    show formatAmount;
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

  Future<bool?> showAmountMismatchDialog(
    BuildContext context, {
    required String entered,
    required String expected,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('orders.returned_amount')),
        content: Text('$entered\n$expected'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.tr('common.confirm')),
          ),
        ],
      ),
    );
  }

  Future<String?> showFailureReasonDialog(BuildContext context) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('orders.failure_reason')),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: dialogContext.tr('orders.failure_reason'),
          ),
          onSubmitted: (_) {
            final reason = controller.text.trim();
            if (reason.isNotEmpty) {
              Navigator.of(dialogContext).pop(reason);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(dialogContext.tr('common.cancel')),
          ),
          FilledButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isNotEmpty) {
                Navigator.of(dialogContext).pop(reason);
              }
            },
            child: Text(dialogContext.tr('common.confirm')),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  Future<double?> showReturnedAmountDialog(
    BuildContext context, {
    String? initialAmount,
  }) async {
    final controller = TextEditingController(text: initialAmount ?? '');
    String? error;

    final result = await showDialog<double>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.tr('orders.returned_amount')),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              errorText: error,
              labelText: context.tr('orders.returned_amount'),
            ),
            onSubmitted: (_) {
              final amount = double.tryParse(controller.text.trim());
              if (amount == null || amount < 0) {
                setState(() => error = context.tr('common.invalid_amount'));
              } else {
                Navigator.of(context).pop(amount);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('common.cancel')),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(controller.text.trim());
                if (amount == null || amount < 0) {
                  setState(() => error = context.tr('common.invalid_amount'));
                } else {
                  Navigator.of(context).pop(amount);
                }
              },
              child: Text(context.tr('common.confirm')),
            ),
          ],
        ),
      ),
    );

    controller.dispose();
    return result;
  }

  Future<void> _onSuccess(BuildContext context, OrderItem order) async {
    final cubit = context.read<CurrentOrdersCubit>();
    final messenger = ScaffoldMessenger.of(context);
    String? initial;

    while (true) {
      final value = await showReturnedAmountDialog(context, initialAmount: initial);
      if (value == null || !context.mounted) return;

      if (!_same(value, order.amount)) {
        final proceed = await showAmountMismatchDialog(
          context,
          entered: formatAmount(context, value),
          expected: formatAmount(context, order.amount),
        );
        if (!context.mounted) return;
        if (proceed != true) {
          initial = value % 1 == 0 ? '${value.toInt()}' : '$value';
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
            child: BlocBuilder<CurrentOrdersCubit, CurrentOrdersState>(
              builder: (context, state) {
                if (state.status == CurrentOrdersStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == CurrentOrdersStatus.failure) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr(
                            state.message ?? 'orders.load_orders_failed',
                          ),
                          style: Styles.textStyle14,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              context.read<CurrentOrdersCubit>().load(),
                          child: Text(context.tr('common.retry')),
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
                              onSuccess: () => _onSuccess(context, order),
                              onFailed: () => _onFailed(context, order),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
