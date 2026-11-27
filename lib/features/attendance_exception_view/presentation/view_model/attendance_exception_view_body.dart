import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/attendance_exception_view/data/fake_exceptions_data.dart';
import 'package:el_karma_ph/features/attendance_exception_view/models/attendance_exception_models.dart';
import 'package:el_karma_ph/features/attendance_exception_view/presentation/widgets/exception_card.dart';
import 'package:el_karma_ph/features/attendance_exception_view/presentation/widgets/exception_editor_dialog.dart';
import 'package:el_karma_ph/features/attendance_exception_view/presentation/widgets/exception_filter_dialog.dart';
import 'package:el_karma_ph/features/employee_details_view/presentation/widgets/edit_dialogs_widget.dart';
import 'package:flutter/material.dart';

/// UI فقط: الداتا وهمية والتعديل/الحذف بيحصلوا في الـ state المحلي.
class AttendanceExceptionViewBody extends StatefulWidget {
  const AttendanceExceptionViewBody({super.key});

  @override
  State<AttendanceExceptionViewBody> createState() =>
      _AttendanceExceptionViewBodyState();
}

class _AttendanceExceptionViewBodyState
    extends State<AttendanceExceptionViewBody> {
  ExceptionsFilter? _filter;
  final List<AttendanceException> _items = buildFakeExceptions();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openFilter();
    });
  }

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  List<AttendanceException> get _visible {
    final f = _filter;
    if (f == null) return const [];
    final from = _dayOf(f.from);
    final to = _dayOf(f.to);
    final list = _items.where((e) {
      final d = _dayOf(e.date);
      return e.employeeId == f.employee.id &&
          !d.isBefore(from) &&
          !d.isAfter(to);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void _snack(String key, {bool ok = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.tr(key)),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
  }

  Future<void> _openFilter() async {
    final result = await showExceptionsFilterDialog(
      context,
      employees: fakeEmployees,
      initial: _filter,
    );
    if (result != null && mounted) setState(() => _filter = result);
  }

  Future<void> _openEditor([AttendanceException? item]) async {
    final filter = _filter;
    if (filter == null) return;

    final result = await showExceptionEditorDialog(
      context,
      employeeId: filter.employee.id,
      initial: item,
    );
    if (result == null || !mounted) return;

    setState(() {
      if (item == null) {
        _items.add(result);
      } else {
        final i = _items.indexWhere((e) => e.id == item.id);
        if (i != -1) _items[i] = result;
      }
    });
    _snack(item == null ? 'exceptions.added' : 'exceptions.updated');
  }

  Future<void> _delete(AttendanceException item) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('exceptions.delete_title'),
      message: context.tr('exceptions.delete_message'),
      confirmLabel: context.tr('common.delete'),
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _items.removeWhere((e) => e.id == item.id));
    _snack('exceptions.deleted');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final filter = _filter;
    final label = filter == null
        ? context.tr('attendance.select_period')
        : '${filter.employee.name}  •  '
              '${formatMediumDate(context, filter.from)}'
              ' - ${formatMediumDate(context, filter.to)}';
    final visible = _visible;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.015,
            ),
            child: Column(
              children: [
                _FilterButton(label: label, onTap: _openFilter),
                const SizedBox(height: 12),
                Expanded(
                  child: filter == null
                      ? _Message(
                          icon: Icons.manage_search_rounded,
                          text: context.tr('exceptions.prompt'),
                        )
                      : visible.isEmpty
                      ? _Message(
                          icon: Icons.event_available_outlined,
                          text: context.tr('exceptions.empty'),
                          hint: context.tr(
                            'exceptions.empty_hint',
                            args: {'name': filter.employee.name},
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: visible.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) => ExceptionCard(
                            item: visible[i],
                            onTap: () => _openEditor(visible[i]),
                            onDelete: () => _delete(visible[i]),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                ButtonWidget(
                  width: double.infinity,
                  height: 52,
                  onPressed: filter == null ? null : () => _openEditor(),
                  backgroundColor: kPrimaryBlue,
                  foregroundColor: Colors.white,
                  text: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        context.tr('exceptions.add'),
                        style: Styles.textStyle16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.person_search_rounded, color: kPrimaryBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.tune_rounded, size: 20, color: kPrimaryBlue),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.hint});

  final IconData icon;
  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final h = hint;
    return Center(
      child: SingleChildScrollView(
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
            if (h != null) ...[
              const SizedBox(height: 6),
              Text(h, style: Styles.textStyle14, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
