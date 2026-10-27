import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/employees_view/repos/employees_repo.dart';
import 'package:el_karma_ph/features/settings_view/manager/repo/attendance_settings_repo.dart';
import 'package:el_karma_ph/features/settings_view/models/attendance_settings.dart';

class DashboardRepo {
  DashboardRepo({
    FirebaseFirestore? firestore,
    EmployeesRepo? employeesRepo,
    AttendanceSettingsRepo? settingsRepo,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _employeesRepo = employeesRepo ?? EmployeesRepo(),
       _settingsRepo = settingsRepo ?? AttendanceSettingsRepo();

  final FirebaseFirestore _db;
  final EmployeesRepo _employeesRepo;
  final AttendanceSettingsRepo _settingsRepo;

  Future<List<EmployeeModel>> getEmployees() => _employeesRepo.getEmployees();

  Future<AttendanceSettings> getSettings() => _settingsRepo.getSettings();

  Future<Map<int, List<DateTime>>> getPunches({
    required Iterable<int> deviceIds,
    required DateTime from,
    required DateTime to,
  }) async {
    final entries = await Future.wait(
      deviceIds.toSet().map((id) async {
        final snapshot = await _db
            .collection(kRawLogsCollection)
            .doc('$id')
            .collection(kPunchesCollection)
            .where(
              kPunchTimestampField,
              isGreaterThanOrEqualTo: Timestamp.fromDate(from),
            )
            .where(kPunchTimestampField, isLessThan: Timestamp.fromDate(to))
            .get();

        final times = <DateTime>[];
        for (final doc in snapshot.docs) {
          final time = doc.data()[kPunchTimestampField];
          if (time is Timestamp) times.add(time.toDate());
        }
        return MapEntry(id, times);
      }),
    );
    return Map.fromEntries(entries);
  }
}
