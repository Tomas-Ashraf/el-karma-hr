import 'employee_enums.dart';
import 'employee_field.dart';

class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.job,
    required this.phone,
    required this.paymentMethod,
    required this.salary,
    required this.deviceId,
    required this.shifts,
    required this.status,
    required this.userType,
  });

  /// Builds a new (not yet saved) employee from the add-member form values.
  factory Employee.fromValues(Map<EmployeeField, String> values) {
    return Employee(
      id: '',
      name: values[EmployeeField.name]!,
      email: values[EmployeeField.email]!,
      job: values[EmployeeField.job]!,
      phone: values[EmployeeField.phone]!,
      paymentMethod:
          PaymentMethod.fromLabel(values[EmployeeField.paymentMethod]!),
      salary: double.parse(values[EmployeeField.salary]!),
      deviceId: values[EmployeeField.deviceId]!,
      shifts: [values[EmployeeField.shift]!],
      status: EmployeeStatus.fromLabel(values[EmployeeField.status]!),
      userType: UserType.fromLabel(values[EmployeeField.userType]!),
    );
  }

  final String id;
  final String name;
  final String email;
  final String job;
  final String phone;
  final PaymentMethod paymentMethod;
  final double salary;
  final String deviceId;

  /// `shifts.first` is "Shift 1"; any further entries are added shifts.
  final List<String> shifts;
  final EmployeeStatus status;
  final UserType userType;

  String valueOf(EmployeeField field) => switch (field) {
        EmployeeField.name => name,
        EmployeeField.email => email,
        EmployeeField.job => job,
        EmployeeField.phone => phone,
        EmployeeField.paymentMethod => paymentMethod.label,
        EmployeeField.salary =>
          salary % 1 == 0 ? salary.toInt().toString() : salary.toString(),
        EmployeeField.deviceId => deviceId,
        EmployeeField.shift => shifts.isEmpty ? '' : shifts.first,
        EmployeeField.status => status.label,
        EmployeeField.userType => userType.label,
      };

  Employee withField(EmployeeField field, String value) => switch (field) {
        EmployeeField.name => copyWith(name: value),
        EmployeeField.email => copyWith(email: value),
        EmployeeField.job => copyWith(job: value),
        EmployeeField.phone => copyWith(phone: value),
        EmployeeField.paymentMethod =>
          copyWith(paymentMethod: PaymentMethod.fromLabel(value)),
        EmployeeField.salary => copyWith(salary: double.parse(value)),
        EmployeeField.deviceId => copyWith(deviceId: value),
        EmployeeField.shift => withShift(0, value),
        EmployeeField.status =>
          copyWith(status: EmployeeStatus.fromLabel(value)),
        EmployeeField.userType => copyWith(userType: UserType.fromLabel(value)),
      };

  Employee withShift(int index, String value) {
    final updated = [...shifts];
    if (index < updated.length) {
      updated[index] = value;
    } else {
      updated.add(value);
    }
    return copyWith(shifts: updated);
  }

  Employee addShift(String period) => copyWith(shifts: [...shifts, period]);

  Employee copyWith({
    String? name,
    String? email,
    String? job,
    String? phone,
    PaymentMethod? paymentMethod,
    double? salary,
    String? deviceId,
    List<String>? shifts,
    EmployeeStatus? status,
    UserType? userType,
  }) {
    return Employee(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      job: job ?? this.job,
      phone: phone ?? this.phone,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      salary: salary ?? this.salary,
      deviceId: deviceId ?? this.deviceId,
      shifts: shifts ?? this.shifts,
      status: status ?? this.status,
      userType: userType ?? this.userType,
    );
  }
}
