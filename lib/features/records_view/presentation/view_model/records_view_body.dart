import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/app_localization/app_localizations.dart';
import 'package:el_karma_ph/core/utils/app_router.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/add_employee_view/presentation/widgets/form_fields.dart';
import 'package:el_karma_ph/features/employee_details_view/presentation/widgets/edit_dialogs_widget.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';
import 'package:el_karma_ph/features/records_view/models/records_mock_data.dart';
import 'package:el_karma_ph/features/records_view/presentation/widgets/record_card.dart';
import 'package:el_karma_ph/features/records_view/presentation/widgets/records_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecordsViewBody extends StatefulWidget {
  const RecordsViewBody({super.key});

  @override
  State<RecordsViewBody> createState() => _RecordsViewBodyState();
}

class _RecordsViewBodyState extends State<RecordsViewBody> {
  final Map<String, List<RecordPreview>> _records = buildMockRecords();
  String? _employeeId;

  RecordsEmployee? get _employee {
    for (final e in kMockEmployees) {
      if (e.id == _employeeId) return e;
    }
    return null;
  }

  Future<void> _deleteRecord(RecordPreview record) async {
    final confirmed = await showConfirmDialog(
      context,
      title: context.tr('records.delete_title'),
      message: context.tr(
        'records.delete_message',
        args: {'period': recordPeriodLabel(context, record)},
      ),
      confirmLabel: context.tr('common.delete'),
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _records[record.employeeId]?.remove(record));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.tr('records.deleted')),
          backgroundColor: Colors.green,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const maxContentWidth = 600.0;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.015,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LabeledDropdown<String>(
                  label: context.tr('attendance.employee'),
                  hint: context.tr('records.select_employee'),
                  initialValue: _employeeId,
                  items: {for (final e in kMockEmployees) e.id: e.name},
                  onChanged: (id) => setState(() => _employeeId = id),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildContent(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final employee = _employee;
    if (employee == null) {
      return RecordsMessage(
        icon: Icons.folder_open_rounded,
        text: context.tr('records.prompt'),
      );
    }

    final records = _records[employee.id] ?? const <RecordPreview>[];
    if (records.isEmpty) {
      return RecordsMessage(
        icon: Icons.event_busy_outlined,
        text: context.tr('records.empty', args: {'name': employee.name}),
        hint: context.tr('records.empty_hint'),
        action: ButtonWidget(
          width: 220,
          height: 48,
          // الإضافة بتتم من شاشة الحضور والانصراف (اختيار الفترة ثم "إضافة سجل").
          onPressed: () =>
              GoRouter.of(context).pushNamed(AppRouter.kAttendanceView),
          backgroundColor: kPrimaryBlue,
          foregroundColor: Colors.white,
          text: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, size: 20),
              const SizedBox(width: 6),
              Text(
                context.tr('attendance.add_record'),
                style: Styles.textStyle16,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: records.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = records[index];
        return RecordCard(
          record: record,
          onTap: () =>
              GoRouter.of(context)
                  .pushNamed(AppRouter.kRecordDetailsView, extra: record),
          onDelete: () => _deleteRecord(record),
        );
      },
    );
  }
}
