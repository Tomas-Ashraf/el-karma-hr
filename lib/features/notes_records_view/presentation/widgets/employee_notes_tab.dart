import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/utils/time_format.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/add_adjustment_dialog.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/adjustment_card.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/notes_filter_dialog.dart';
import 'package:flutter/material.dart';

class EmployeeNotesTab extends StatefulWidget {
  const EmployeeNotesTab({super.key});

  @override
  State<EmployeeNotesTab> createState() => _EmployeeNotesTabState();
}

class _EmployeeNotesTabState extends State<EmployeeNotesTab>
    with AutomaticKeepAliveClientMixin {
  final List<EmployeeAdjustment> _all = [...dummyAdjustments];
  NotesFilter? _filter;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // أول ما التاب يتفتح يظهر dialog اختيار الموظف والمدة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openFilter();
    });
  }

  Future<void> _openFilter() async {
    final result = await showNotesFilterDialog(context, initial: _filter);
    if (result != null && mounted) setState(() => _filter = result);
  }

  Future<void> _openAdd() async {
    final result = await showAddAdjustmentDialog(
      context,
      initialEmployee: _filter?.employee,
    );
    if (result == null || !mounted) return;
    setState(() => _all.insert(0, result));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.tr('notes.added')),
          backgroundColor: Colors.green,
        ),
      );
  }

  List<EmployeeAdjustment> get _visible {
    final f = _filter;
    if (f == null) return const [];
    final from = DateTime(f.from.year, f.from.month, f.from.day);
    final end = DateTime(f.to.year, f.to.month, f.to.day + 1);
    return _all
        .where(
          (a) =>
              a.employeeName == f.employee &&
              !a.date.isBefore(from) &&
              a.date.isBefore(end),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenSize = MediaQuery.of(context).size;
    final filter = _filter;
    final items = _visible;

    final label = filter == null
        ? context.tr('attendance.select_period')
        : '${filter.employee}  •  ${formatMediumDate(context, filter.from)}'
              ' - ${formatMediumDate(context, filter.to)}';

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
                          text: context.tr('notes.prompt'),
                        )
                      : items.isEmpty
                      ? _Message(
                          icon: Icons.inbox_outlined,
                          text: context.tr('notes.no_adjustments'),
                          hint: context.tr(
                            'notes.no_adjustments_hint',
                            args: {'name': filter.employee},
                          ),
                        )
                      : Column(
                          children: [
                            _TotalsRow(items: items),
                            const SizedBox(height: 12),
                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.only(bottom: 8),
                                itemCount: items.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, i) =>
                                    AdjustmentCard(item: items[i]),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                ButtonWidget(
                  width: double.infinity,
                  height: 52,
                  onPressed: _openAdd,
                  backgroundColor: kPrimaryBlue,
                  foregroundColor: Colors.white,
                  text: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        context.tr('notes.add_adjustment'),
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

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.items});

  final List<EmployeeAdjustment> items;

  @override
  Widget build(BuildContext context) {
    final bonus = items
        .where((e) => e.isBonus)
        .fold(0.0, (s, e) => s + e.amount);
    final ded = items
        .where((e) => !e.isBonus)
        .fold(0.0, (s, e) => s + e.amount);

    Widget chip(String label, double value, Color color) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(31),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: color)),
            const SizedBox(height: 2),
            Text(
              formatAmount(context, value),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );

    return Row(
      children: [
        chip(context.tr('notes.bonus'), bonus, kBonusColor),
        const SizedBox(width: 10),
        chip(context.tr('notes.deduction'), ded, kDeductionColor),
      ],
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
