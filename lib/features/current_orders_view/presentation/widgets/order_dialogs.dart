import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

ButtonStyle _primary([Color color = kPrimaryBlue]) => ElevatedButton.styleFrom(
  backgroundColor: color,
  foregroundColor: Colors.white,
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
);

Future<double?> showReturnedAmountDialog(
  BuildContext context, {
  String? initial,
}) {
  return showDialog<double>(
    context: context,
    builder: (_) => _ReturnedAmountDialog(initial: initial),
  );
}

class _ReturnedAmountDialog extends StatefulWidget {
  const _ReturnedAmountDialog({this.initial});
  final String? initial;

  @override
  State<_ReturnedAmountDialog> createState() => _ReturnedAmountDialogState();
}

class _ReturnedAmountDialogState extends State<_ReturnedAmountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    final text = v?.trim() ?? '';
    if (text.isEmpty) return context.tr('common.required');
    final n = double.tryParse(text);
    if (n == null || n < 0) return context.tr('settings.invalid_amount');
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(double.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        context.tr('orders.returned_amount_title'),
        style: _titleStyle,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('orders.returned_amount_hint'),
                  style: Styles.textStyle14,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  validator: _validate,
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
                  decoration: appInputDecoration(
                    context,
                    suffixText: context.tr('common.egp'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('common.cancel')),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: _primary(),
          child: Text(context.tr('common.confirm')),
        ),
      ],
    );
  }
}

Future<bool?> showAmountMismatchDialog(
  BuildContext context, {
  required String entered,
  required String expected,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ctx.tr('orders.amount_mismatch_title'),
              style: _titleStyle,
            ),
          ),
        ],
      ),
      content: Text(
        ctx.tr(
          'orders.amount_mismatch_message',
          args: {'entered': entered, 'expected': expected},
        ),
        style: Styles.textStyle14,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(ctx.tr('common.no')),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: _primary(),
          child: Text(ctx.tr('common.yes')),
        ),
      ],
    ),
  );
}

Future<String?> showFailureReasonDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _FailureReasonDialog(),
  );
}

class _FailureReasonDialog extends StatefulWidget {
  const _FailureReasonDialog();

  @override
  State<_FailureReasonDialog> createState() => _FailureReasonDialogState();
}

class _FailureReasonDialogState extends State<_FailureReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(context.tr('orders.failure_title'), style: _titleStyle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('orders.failure_hint'),
                style: Styles.textStyle14,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: appInputDecoration(context),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('common.cancel')),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          style: _primary(kDeductionColor),
          child: Text(context.tr('orders.done')),
        ),
      ],
    );
  }
}
