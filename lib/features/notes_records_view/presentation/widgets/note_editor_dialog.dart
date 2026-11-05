import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:flutter/material.dart';

typedef NoteDraft = ({String title, String body, int colorIndex});

Future<NoteDraft?> showNoteEditorDialog(
  BuildContext context, {
  PersonalNote? initial,
}) {
  return showDialog<NoteDraft>(
    context: context,
    builder: (_) => _NoteEditorDialog(initial: initial),
  );
}

class _NoteEditorDialog extends StatefulWidget {
  const _NoteEditorDialog({this.initial});

  final PersonalNote? initial;

  @override
  State<_NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends State<_NoteEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _body = TextEditingController(text: widget.initial?.body);
  late int _color = widget.initial?.colorIndex ?? 0;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? context.tr('common.required') : null;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((
      title: _title.text.trim(),
      body: _body.text.trim(),
      colorIndex: _color,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        context.tr(isEdit ? 'notes.edit_note' : 'notes.add_note'),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                LabeledTextField(
                  label: context.tr('notes.note_title'),
                  controller: _title,
                  validator: _required,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                Text(context.tr('notes.note_body'), style: Styles.textStyle13),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _body,
                  validator: _required,
                  minLines: 4,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: appInputDecoration(context),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (var i = 0; i < kNoteColorsLight.length; i++)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _color = i),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: context.noteColor(i),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _color == i
                                    ? context.colors.onSurface
                                    : context.colors.outlineVariant,
                                width: _color == i ? 2 : 1,
                              ),
                            ),
                            child: _color == i
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: context.colors.onSurface,
                                  )
                                : null,
                          ),
                        ),
                      ),
                  ],
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
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(context.tr('common.save')),
        ),
      ],
    );
  }
}
