import 'employee_enums.dart';

/// Every editable value of an employee, in display order.
enum EmployeeField {
  name('Name'),
  email('Email'),
  job('Job'),
  phone('Phone number'),
  paymentMethod('Payment method'),
  salary('Salary'),
  deviceId('Device ID'),
  shift('Shift 1 period'),
  status('Status'),
  userType('User type');

  const EmployeeField(this.label);
  final String label;

  /// Non-null for fields that are picked from a fixed list.
  List<String>? get options => switch (this) {
        paymentMethod => PaymentMethod.values.map((e) => e.label).toList(),
        status => EmployeeStatus.values.map((e) => e.label).toList(),
        userType => UserType.values.map((e) => e.label).toList(),
        _ => null,
      };
}
