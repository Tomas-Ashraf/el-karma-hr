import 'package:el_karma_ph/core/utils/employee/employee.dart';
import 'package:el_karma_ph/core/utils/employee/employee_enums.dart';
import 'package:el_karma_ph/core/utils/employee/employee_field.dart';

const jobs = [
  'Cashier',
  'Store Manager',
  'Sales Associate',
  'Supervisor',
  'Stock Keeper',
];

Employee employeeFromValues(String id, Map<EmployeeField, String> values) {
  return Employee(
    id: id,
    name: values[EmployeeField.name] ?? '',
    email: values[EmployeeField.email] ?? '',
    job: values[EmployeeField.job] ?? '',
    phone: values[EmployeeField.phone] ?? '',
    paymentMethod: PaymentMethod.values.firstWhere(
      (method) =>
          method.name.toLowerCase() ==
          (values[EmployeeField.paymentMethod] ?? '').toLowerCase(),
      orElse: () => PaymentMethod.values.first,
    ),
    salary: double.tryParse(values[EmployeeField.salary] ?? '') ?? 0,
    deviceId: values[EmployeeField.deviceId] ?? '',
    shifts: [values[EmployeeField.shift] ?? ''],
    status: EmployeeStatus.values.firstWhere(
      (status) =>
          status.name.toLowerCase() ==
          (values[EmployeeField.status] ?? '').toLowerCase(),
      orElse: () => EmployeeStatus.values.first,
    ),
    userType: UserType.values.firstWhere(
      (type) =>
          type.name.toLowerCase() ==
          (values[EmployeeField.userType] ?? '').toLowerCase(),
      orElse: () => UserType.values.first,
    ),
  );
}
