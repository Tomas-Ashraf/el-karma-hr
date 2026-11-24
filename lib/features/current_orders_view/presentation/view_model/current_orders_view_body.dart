import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/current_orders_view/models/fake_orders.dart';
import 'package:el_karma_ph/features/current_orders_view/presentation/widgets/empty_state.dart';
import 'package:el_karma_ph/features/current_orders_view/presentation/widgets/order_card.dart';
import 'package:flutter/material.dart';

class CurrentOrdersViewBody extends StatefulWidget {
  const CurrentOrdersViewBody({super.key});

  @override
  State<CurrentOrdersViewBody> createState() => _CurrentOrdersViewBodyState();
}

class _CurrentOrdersViewBodyState extends State<CurrentOrdersViewBody> {
  // UI فقط: نسخة محلية من الداتا الوهمية عشان نقدر نغيّر الحالة قدام العين.
  late final List<OrderItem> _orders = [...fakeOrders];

  void _setStatus(OrderItem order, OrderStatus status) {
    if (order.status == status) return;
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index == -1) return;

    setState(() => _orders[index] = order.copyWith(status: status));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.tr('orders.status_updated')),
          backgroundColor: status == OrderStatus.success
              ? Colors.green
              : Colors.red,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 600.0;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
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
                        style: Styles.textStyle14,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: _orders.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            return OrderCard(
                              order: order,
                              onSuccess: () =>
                                  _setStatus(order, OrderStatus.success),
                              onFailed: () =>
                                  _setStatus(order, OrderStatus.failed),
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
