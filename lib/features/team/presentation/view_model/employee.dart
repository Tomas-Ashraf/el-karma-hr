import 'employee_field.dart';

/// Simple mutable model: every value lives in [values], keyed by its field.
/// Shift 1 is `values[EmployeeField.shift]`; any added shifts are in [extraShifts].
class Employee {
  Employee(this.id, this.values, {List<String>? extraShifts})
      : extraShifts = extraShifts ?? [];

  final String id;
  final Map<EmployeeField, String> values;
  final List<String> extraShifts;

  String get name => values[EmployeeField.name] ?? '';
  String get job => values[EmployeeField.job] ?? '';
}
