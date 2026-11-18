import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:el_karma_ph/features/orders_recording_view/models/fake_delivery_men.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class OrdersRecordingViewBody extends StatefulWidget {
  const OrdersRecordingViewBody({super.key});

  @override
  State<OrdersRecordingViewBody> createState() =>
      _OrdersRecordingViewBodyState();
}

class _OrdersRecordingViewBodyState extends State<OrdersRecordingViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();

  String? _deliveryId;

  @override
  void dispose() {
    _referenceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.tr('common.required');
    }
    return null;
  }

  String? _validateAmount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.tr('common.required');
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      return context.tr('settings.invalid_amount');
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // UI فقط: مفيش حفظ حالياً.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.tr('orders.added')),
          backgroundColor: Colors.green,
        ),
      );
    GoRouter.of(context).pushNamed(AppRouter.kCurrentOrdersView);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 600.0;
    const gap = SizedBox(height: 16);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.02,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabeledDropdown<String>(
                    label: context.tr('orders.delivery_man'),
                    hint: context.tr('add_employee.select'),
                    initialValue: _deliveryId,
                    items: {for (final d in fakeDeliveryMen) d.id: d.name},
                    validator: (v) =>
                        v == null ? context.tr('common.required') : null,
                    onChanged: (v) => _deliveryId = v,
                  ),
                  gap,
                  LabeledTextField(
                    label: context.tr('orders.customer_or_invoice'),
                    controller: _referenceController,
                    validator: _required,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('orders.customer_or_invoice_hint'),
                    style: Styles.textStyle14,
                  ),
                  gap,
                  LabeledTextField(
                    label: context.tr('orders.amount'),
                    controller: _amountController,
                    validator: _validateAmount,
                    suffixText: context.tr('common.egp'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('orders.amount_hint'),
                    style: Styles.textStyle14,
                  ),
                  const SizedBox(height: 24),
                  ButtonWidget(
                    width: double.infinity,
                    height: 52,
                    onPressed: _submit,
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: Colors.white,
                    text: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('orders.submit'),
                          style: Styles.textStyle16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
