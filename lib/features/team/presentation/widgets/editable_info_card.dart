import 'package:el_karma_ph/core/app_colors.dart';
import 'package:flutter/material.dart';

import 'info_card.dart';

/// [InfoCard] that swaps its value for a text field or dropdown while editing.
class EditableInfoCard extends StatefulWidget {
  const EditableInfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.isEditing,
    required this.onEdit,
    required this.onSave,
    this.options,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final String value;
  final bool isEditing;
  final VoidCallback onEdit;
  final ValueChanged<String> onSave;
  final List<String>? options;
  final TextInputType keyboardType;

  @override
  State<EditableInfoCard> createState() => _EditableInfoCardState();
}

class _EditableInfoCardState extends State<EditableInfoCard> {
  static const _valueStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );
  static const _underline = UnderlineInputBorder(
    borderSide: BorderSide(color: AppColors.blue, width: 2),
  );

  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  late String _selected = widget.value;

  @override
  void didUpdateWidget(EditableInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isEditing && widget.isEditing) {
      _controller.text = widget.value;
      _selected = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _draft => widget.options != null ? _selected : _controller.text;

  Widget _buildEditor() {
    final options = widget.options;
    if (options != null) {
      return DropdownButton<String>(
        isExpanded: true,
        isDense: true,
        value: _selected,
        underline: Container(height: 2, color: AppColors.blue),
        items: [
          for (final o in options) DropdownMenuItem(value: o, child: Text(o)),
        ],
        onChanged: (v) => setState(() => _selected = v ?? _selected),
      );
    }
    return TextField(
      controller: _controller,
      autofocus: true,
      keyboardType: widget.keyboardType,
      style: _valueStyle,
      onSubmitted: (_) => widget.onSave(_draft),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 4),
        enabledBorder: _underline,
        focusedBorder: _underline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      label: widget.label,
      actionLabel: widget.isEditing ? 'Save' : 'Edit',
      onAction: () =>
          widget.isEditing ? widget.onSave(_draft) : widget.onEdit(),
      child: widget.isEditing
          ? _buildEditor()
          : Text(widget.value.isEmpty ? '—' : widget.value, style: _valueStyle),
    );
  }
}
