part of 'employees_cubit.dart';

sealed class EmployeesState {}

final class EmployeesInitial extends EmployeesState {}

final class EmployeesLoading extends EmployeesState {}

final class EmployeesSuccess extends EmployeesState {
  final List<EmployeeModel> employees;

  EmployeesSuccess(this.employees);
}

final class EmployeesFailure extends EmployeesState {
  final String errorMessage;

  EmployeesFailure(this.errorMessage);
}
