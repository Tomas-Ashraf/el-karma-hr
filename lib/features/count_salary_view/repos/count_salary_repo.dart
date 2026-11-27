import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/employee_jobs.dart';
import 'package:el_karma_ph/features/count_salary_view/manager/logic/salary_calculator.dart';
import 'package:el_karma_ph/features/count_salary_view/models/salary_sheet.dart';
import 'package:el_karma_ph/features/count_salary_view/repos/salary_sheets_repo.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/employees_view/repos/employees_repo.dart';
import 'package:el_karma_ph/features/finished_orders_view/models/finished_order.dart';
import 'package:el_karma_ph/features/finished_orders_view/repos/finished_orders_repo.dart';
import 'package:el_karma_ph/features/notes_records_view/models/notes_models.dart';
import 'package:el_karma_ph/features/notes_records_view/repos/notes_repo.dart';
import 'package:el_karma_ph/features/records_view/models/record_preview_models.dart';
import 'package:el_karma_ph/features/records_view/repos/saved_records_repo.dart';
import 'package:el_karma_ph/features/settings_view/manager/repo/attendance_settings_repo.dart';

class CountSalaryRepo {
  CountSalaryRepo({
    EmployeesRepo? employeesRepo,
    SavedRecordsRepo? recordsRepo,
    NotesRepo? notesRepo,
    FinishedOrdersRepo? ordersRepo,
    AttendanceSettingsRepo? settingsRepo,
    SalarySheetsRepo? sheetsRepo,
  }) : _employeesRepo = employeesRepo ?? EmployeesRepo(),
       _recordsRepo = recordsRepo ?? SavedRecordsRepo(),
       _notesRepo = notesRepo ?? NotesRepo(),
       _ordersRepo = ordersRepo ?? FinishedOrdersRepo(),
       _settingsRepo = settingsRepo ?? AttendanceSettingsRepo(),
       _sheetsRepo = sheetsRepo ?? SalarySheetsRepo();

  final EmployeesRepo _employeesRepo;
  final SavedRecordsRepo _recordsRepo;
  final NotesRepo _notesRepo;
  final FinishedOrdersRepo _ordersRepo;
  final AttendanceSettingsRepo _settingsRepo;
  final SalarySheetsRepo _sheetsRepo;

  Future<List<EmployeeModel>> getEmployees() => _employeesRepo.getEmployees();

  Future<List<RecordPreview>> getRecords(EmployeeModel employee) => _recordsRepo
      .getRecords(RecordsEmployee(id: employee.id, name: employee.name));

  Future<SalarySheet> buildSheet(
    EmployeeModel employee,
    RecordPreview record,
  ) async {
    final isDelivery = normalizeJob(employee.job) == kDeliveryJob;

    final adjustmentsFuture = _notesRepo.getAdjustments(
      employee.id,
      record.from,
      record.to,
    );
    final ordersFuture = isDelivery
        ? _ordersRepo.getOrders(record.from, record.to)
        : Future.value(const <FinishedOrder>[]);
    final perMinuteFuture = record.deductionPerMinute != null
        ? Future.value(record.deductionPerMinute!)
        : _settingsRepo.getSettings().then((s) => s.deductionPerMinute);

    final results = await Future.wait<Object>([
      adjustmentsFuture,
      ordersFuture,
      perMinuteFuture,
    ]);

    final adjustments = results[0] as List<EmployeeAdjustment>;
    final orders = results[1] as List<FinishedOrder>;
    final perMinute = results[2] as double;

    final calculated = SalaryCalculator.calculate(
      employee: employee,
      record: record,
      adjustments: adjustments,
      deliveryOrdersCount: orders
          .where((o) => o.deliveryManId == employee.id)
          .length,
      deductionPerMinute: perMinute,
    );
    final saved = await _sheetsRepo.getSaved(employee.id, record.id);
    return applySaved(calculated, saved);
  }

  Future<Map<String, SalaryStatus>> getStatuses(EmployeeModel employee) =>
      _sheetsRepo.getStatuses(employee.id);
}
