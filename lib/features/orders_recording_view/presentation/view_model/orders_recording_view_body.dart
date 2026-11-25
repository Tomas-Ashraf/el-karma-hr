import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:el_karma_ph/features/orders_recording_view/manager/cubit/orders_recording_cubit.dart';
import 'package:el_karma_ph/features/orders_recording_view/manager/cubit/orders_recording_state.dart';
import 'package:el_karma_ph/features/orders_recording_view/models/new_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    final cubit = context.read<OrdersRecordingCubit>();
    final deliveryMan = cubit.state.deliveryMen.firstWhere(
      (d) => d.id == _deliveryId,
    );

    cubit.addOrder(
      NewOrder(
        deliveryMan: deliveryMan,
        reference: _referenceController.text,
        amount: double.parse(_amountController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrdersRecordingCubit, OrdersRecordingState>(
      listenWhen: (previous, current) =>
          previous.submitStatus != current.submitStatus &&
          (current.submitStatus == OrderSubmitStatus.saved ||
              current.submitStatus == OrderSubmitStatus.failed),
      listener: (context, state) {
        final saved = state.submitStatus == OrderSubmitStatus.saved;
        // بعد النجاح بنفضي الحقول ونسيب المندوب مختار
        if (saved) _formKey.currentState?.reset();

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                context.tr(
                  saved
                      ? 'orders.added'
                      : (state.message ?? 'orders.add_failed'),
                ),
              ),
              backgroundColor: saved ? Colors.green : Colors.red,
            ),
          );
      },
      builder: (context, state) {
        switch (state.status) {
          case OrdersRecordingStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case OrdersRecordingStatus.failure:
            return _Message(
              icon: Icons.error_outline_rounded,
              text: context.tr(state.message ?? 'orders.load_failed'),
              action: TextButton(
                onPressed: () =>
                    context.read<OrdersRecordingCubit>().loadDeliveryMen(),
                child: Text(context.tr('common.retry')),
              ),
            );

          case OrdersRecordingStatus.ready:
            if (state.deliveryMen.isEmpty) {
              return _Message(
                icon: Icons.motorcycle_rounded,
                text: context.tr('orders.no_delivery_men'),
                hint: context.tr('orders.no_delivery_men_hint'),
              );
            }
            return _buildForm(context, state);
        }
      },
    );
  }

  Widget _buildForm(BuildContext context, OrdersRecordingState state) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 600.0;
    const gap = SizedBox(height: 16);
    final isSaving = state.submitStatus == OrderSubmitStatus.saving;

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
                    items: {for (final d in state.deliveryMen) d.id: d.name},
                    validator: (v) =>
                        v == null ? context.tr('common.required') : null,
                    // setState عشان الـ reset بعد الإضافة يحافظ على الاختيار
                    onChanged: (v) => setState(() => _deliveryId = v),
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
                    onFieldSubmitted: (_) {
                      if (!isSaving) _submit();
                    },
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
                    onPressed: () {
                      if (isSaving) return;
                      _submit();
                    },
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: Colors.white,
                    text: isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
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

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.hint,
    this.action,
  });

  final IconData icon;
  final String text;
  final String? hint;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final hintText = hint;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
              child: Icon(icon, size: 34, color: kPrimaryBlue),
            ),
            const SizedBox(height: 16),
            Text(text, style: Styles.textStyle16, textAlign: TextAlign.center),
            if (hintText != null) ...[
              const SizedBox(height: 6),
              Text(
                hintText,
                style: Styles.textStyle14,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}
