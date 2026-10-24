import 'package:el_karma_ph/core/utils/employee/employee.dart';
import 'package:el_karma_ph/features/employees_view/presentation/view_model/spam_data/names.dart';

final List<Employee> employees = List.generate(5, (i) => fakeEmployee(i + 1));
int lastId = 5;
String query = '';

List<Employee> get visible {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return employees;
  return employees
      .where((e) => '${e.name} ${e.job}'.toLowerCase().contains(q))
      .toList();
}
