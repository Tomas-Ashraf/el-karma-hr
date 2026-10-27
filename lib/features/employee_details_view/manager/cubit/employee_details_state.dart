import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';

enum EmployeeDetailsStatus { idle, saving, saved, failure }

class EmployeeDetailsState {
  const EmployeeDetailsState({
    required this.employee,
    this.status = EmployeeDetailsStatus.idle,
    this.message,
  });

  final EmployeeModel employee;
  final EmployeeDetailsStatus status;
  final String? message;

  EmployeeDetailsState copyWith({
    EmployeeDetailsStatus? status,
    String? message,
  }) {
    return EmployeeDetailsState(
      employee: employee,
      status: status ?? this.status,
      message: message,
    );
  }
}
