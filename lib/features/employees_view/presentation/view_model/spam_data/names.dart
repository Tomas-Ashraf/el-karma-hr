import 'package:el_karma_ph/core/utils/employee/employee.dart';
import 'package:el_karma_ph/core/utils/employee/employee_field.dart';
import 'package:el_karma_ph/features/employees_view/presentation/view_model/spam_data/jobs.dart';

const names = [
  'Jane Hawkins',
  'Brooklyn Simmons',
  'Leslie Alexander',
  'Ronald Richards',
  'Jenny Wilson',
];

/// Builds a demo employee. The first 5 get real-looking names, the rest "Member N".
Employee fakeEmployee(int n) {
  final name = n <= names.length ? names[n - 1] : 'Member $n';
  return employeeFromValues('$n', {
    EmployeeField.name: name,
    EmployeeField.email: '${name.toLowerCase().replaceAll(' ', '')}@demo.com',
    EmployeeField.job: jobs[(n - 1) % jobs.length],
    EmployeeField.phone: '+20 100 123 ${4500 + n}',
    EmployeeField.paymentMethod: 'Cash',
    EmployeeField.salary: '${6000 + n * 100}',
    EmployeeField.deviceId: 'DV-${1000 + n}',
    EmployeeField.shift: '08:00 AM - 04:00 PM',
    EmployeeField.status: 'Active',
    EmployeeField.userType: 'Employee',
  });
}
