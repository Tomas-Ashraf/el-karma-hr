import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/employee_details_view/presentation/widgets/edit_dialogs_widget.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/note_editor_dialog.dart';
import 'package:flutter/material.dart';

class PersonalNotesTab extends StatefulWidget {
  const PersonalNotesTab({super.key});

  @override
  State<PersonalNotesTab> createState() => _PersonalNotesTabState();
}

class _PersonalNotesTabState extends State<PersonalNotesTab>
    with AutomaticKeepAliveClientMixin {
  final List<PersonalNote> _notes = [...dummyPersonalNotes];

  @override
  bool get wantKeepAlive => true;

  Future<void> _openEditor([PersonalNote? note]) async {
    final draft = await showNoteEditorDialog(context, initial: note);
    if (draft == null || !mounted) return;
    setState(() {
      final updated = PersonalNote(
        id: note?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: draft.title,
        body: draft.body,
        date: DateTime.now(),
        colorIndex: draft.colorIndex,
      );
      if (note == null) {
        _notes.insert(0, updated);
      } else {
        final i = _notes.indexWhere((n) => n.id == note.id);
        if (i != -1) _notes[i] = updated;
      }
    });
  }

  Future<void> _delete(PersonalNote note) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('notes.delete_note_title'),
      message: context.tr('notes.delete_note_message'),
      confirmLabel: context.tr('common.delete'),
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _notes.removeWhere((n) => n.id == note.id));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _notes.isEmpty
                ? const _EmptyNotes()
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      screenSize.width * 0.05,
                      screenSize.height * 0.02,
                      screenSize.width * 0.05,
                      90,
                    ),
                    itemCount: _notes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return _NoteCard(
                        note: note,
                        onTap: () => _openEditor(note),
                        onDelete: () => _delete(note),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final PersonalNote note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDark;
    final accent = kNoteColorsLight[note.colorIndex % kNoteColorsLight.length];

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: colors.outlineVariant) : null,
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadiusDirectional.horizontal(
                      start: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatMediumDate(context, note.date),
                          style: TextStyle(fontSize: 11, color: accent),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: context.tr('common.delete'),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 22,
                    color: kDeductionColor,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

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
              Icons.sticky_note_2_outlined,
              size: 34,
              color: kPrimaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(context.tr('notes.personal_empty'), style: Styles.textStyle16),
          const SizedBox(height: 6),
          Text(
            context.tr('notes.personal_empty_hint'),
            style: Styles.textStyle14,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
