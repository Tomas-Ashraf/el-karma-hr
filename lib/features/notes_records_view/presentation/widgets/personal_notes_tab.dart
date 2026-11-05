import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/features/employee_details_view/presentation/widgets/edit_dialogs_widget.dart';
import 'package:el_karma_ph/features/notes_records_view/manager/cubit/personal_notes_cubit.dart';
import 'package:el_karma_ph/features/notes_records_view/manager/cubit/personal_notes_state.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/note_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalNotesTab extends StatefulWidget {
  const PersonalNotesTab({super.key});

  @override
  State<PersonalNotesTab> createState() => _PersonalNotesTabState();
}

class _PersonalNotesTabState extends State<PersonalNotesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (_) => PersonalNotesCubit()..load(),
      child: const _PersonalNotesView(),
    );
  }
}

class _PersonalNotesView extends StatelessWidget {
  const _PersonalNotesView();

  void _snack(ScaffoldMessengerState messenger, String text, bool ok) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
  }

  Future<void> _openEditor(BuildContext context, [PersonalNote? note]) async {
    final cubit = context.read<PersonalNotesCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final draft = await showNoteEditorDialog(context, initial: note);
    if (draft == null) return;

    final error = await cubit.save(
      note: note,
      title: draft.title,
      body: draft.body,
      colorIndex: draft.colorIndex,
    );
    if (error != null && context.mounted) {
      _snack(messenger, context.tr(error), false);
    }
  }

  Future<void> _delete(BuildContext context, PersonalNote note) async {
    final cubit = context.read<PersonalNotesCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('notes.delete_note_title'),
      message: context.tr('notes.delete_note_message'),
      confirmLabel: context.tr('common.delete'),
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    final error = await cubit.delete(note);
    if (!context.mounted) return;
    _snack(messenger, context.tr(error ?? 'notes.deleted'), error == null);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
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
            child: BlocBuilder<PersonalNotesCubit, PersonalNotesState>(
              builder: (context, state) {
                if (state.status == NotesLoadStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == NotesLoadStatus.failure) {
                  return _ErrorState(
                    message: context.tr(state.message ?? 'notes.load_failed'),
                    onRetry: () => context.read<PersonalNotesCubit>().load(),
                  );
                }

                if (state.notes.isEmpty) return const _EmptyNotes();

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<PersonalNotesCubit>().load(silent: true),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      screenSize.width * 0.05,
                      screenSize.height * 0.02,
                      screenSize.width * 0.05,
                      90,
                    ),
                    itemCount: state.notes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final note = state.notes[index];
                      return _NoteCard(
                        note: note,
                        onTap: () => _openEditor(context, note),
                        onDelete: () => _delete(context, note),
                      );
                    },
                  ),
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

    return Container(
      decoration: BoxDecoration(
        color: context.noteColor(note.colorIndex),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
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
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 4, 12),
            child: Row(
              children: [
                Expanded(
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
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: Styles.textStyle14, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(context.tr('common.retry')),
          ),
        ],
      ),
    );
  }
}
