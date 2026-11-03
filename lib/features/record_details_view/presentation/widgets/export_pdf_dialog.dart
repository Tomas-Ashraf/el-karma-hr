import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/whatsapp_sender.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showExportPdfDialog(
  BuildContext context, {
  required VoidCallback onPreview,
  required VoidCallback onWhatsApp,
  required VoidCallback onShare,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ExportPdfDialog(
      onPreview: onPreview,
      onWhatsApp: onWhatsApp,
      onShare: onShare,
    ),
  );
}

class _ExportPdfDialog extends StatelessWidget {
  const _ExportPdfDialog({
    required this.onPreview,
    required this.onWhatsApp,
    required this.onShare,
  });

  final VoidCallback onPreview;
  final VoidCallback onWhatsApp;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 22,
              color: Color(0xFF22C55E),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.tr('export.title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.tr('export.subtitle'), style: Styles.textStyle14),
              const SizedBox(height: 16),
              _ActionButton(
                icon: Icons.visibility_outlined,
                label: context.tr('export.preview'),
                onPressed: onPreview,
              ),
              const SizedBox(height: 10),
              _ActionButton(
                icon: Icons.chat_rounded,
                label: context.tr('export.send_whatsapp'),
                onPressed: onWhatsApp,
                filled: true,
              ),
              const SizedBox(height: 10),
              _ActionButton(
                icon: Icons.ios_share_rounded,
                label: context.tr('export.share'),
                onPressed: onShare,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('export.close')),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ButtonWidget(
        width: double.infinity,
        height: 48,
        onPressed: onPressed,
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
        text: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(label, style: Styles.textStyle16),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: Styles.textStyle16),
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimaryBlue,
          side: const BorderSide(color: kPrimaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

Future<String?> showWhatsappTargetDialog(
  BuildContext context, {
  required String employeePhone,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _WhatsappTargetDialog(employeePhone: employeePhone),
  );
}

class _WhatsappTargetDialog extends StatefulWidget {
  const _WhatsappTargetDialog({required this.employeePhone});

  final String employeePhone;

  @override
  State<_WhatsappTargetDialog> createState() => _WhatsappTargetDialogState();
}

class _WhatsappTargetDialogState extends State<_WhatsappTargetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  late final String? _employeeNumber = normalizeWhatsAppNumber(
    widget.employeePhone,
  );
  late bool _useEmployee = _employeeNumber != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_useEmployee) {
      Navigator.of(context).pop(_employeeNumber);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(normalizeWhatsAppNumber(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = widget.employeePhone.trim().isNotEmpty;

    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        context.tr('whatsapp.title'),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ChoiceTile(
                  selected: _useEmployee,
                  title: context.tr('whatsapp.employee_number'),
                  subtitle: hasPhone
                      ? widget.employeePhone.trim()
                      : context.tr('whatsapp.no_employee_number'),
                  onTap: _employeeNumber == null
                      ? null
                      : () => setState(() => _useEmployee = true),
                ),
                const SizedBox(height: 10),
                _ChoiceTile(
                  selected: !_useEmployee,
                  title: context.tr('whatsapp.custom_number'),
                  onTap: () => setState(() => _useEmployee = false),
                  child: _useEmployee
                      ? null
                      : TextFormField(
                          controller: _controller,
                          autofocus: true,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+ ]'),
                            ),
                            LengthLimitingTextInputFormatter(18),
                          ],
                          validator: (v) =>
                              normalizeWhatsAppNumber(v ?? '') == null
                              ? context.tr('whatsapp.invalid_number')
                              : null,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: appInputDecoration(
                            context,
                            hintText: '01012345678',
                          ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(context.tr('whatsapp.open')),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.selected,
    required this.title,
    this.subtitle,
    this.onTap,
    this.child,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sub = subtitle;
    final extra = child;

    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: selected ? kPrimaryBlue.withAlpha(20) : null,
              border: Border.all(
                color: selected ? kPrimaryBlue : colors.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? kPrimaryBlue : colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (sub != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              sub,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (extra != null) ...[const SizedBox(height: 12), extra],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
