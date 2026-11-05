import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/app_theme/app_theme.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/employee_notes_tab.dart';
import 'package:el_karma_ph/features/notes_records_view/presentation/widgets/personal_notes_tab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotesRecordsView extends StatefulWidget {
  const NotesRecordsView({super.key});

  @override
  State<NotesRecordsView> createState() => _NotesRecordsViewState();
}

class _NotesRecordsViewState extends State<NotesRecordsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      if (_tabController.index != _index) {
        setState(() => _index = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(context.tr('notes.title'), style: Styles.textStyle20),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            final router = GoRouter.of(context);
            router.canPop()
                ? router.pop()
                : router.go(AppRouter.kDashboardView);
          },
        ),
        actions: [
          if (_index == 1) ...[
            IconButton(
              tooltip: context.tr('notes.summary_title'),
              icon: const Icon(Icons.bar_chart_rounded, color: kPrimaryBlue),
              onPressed: () =>
                  GoRouter.of(context).pushNamed(AppRouter.kNotesSummaryView),
            ),
            const SizedBox(width: 4),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: kPrimaryBlue,
          indicatorColor: kPrimaryBlue,
          unselectedLabelColor: context.colors.onSurfaceVariant,
          labelStyle: Styles.textStyle16,
          tabs: [
            Tab(text: context.tr('notes.tab_personal')),
            Tab(text: context.tr('notes.tab_employees')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [PersonalNotesTab(), EmployeeNotesTab()],
      ),
    );
  }
}
