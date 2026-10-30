part of 'add_employee_cubit.dart';

sealed class AddEmployeeState {}

final class AddEmployeeInitial extends AddEmployeeState {}

final class AddEmployeeLoading extends AddEmployeeState {}

final class AddEmployeeSuccess extends AddEmployeeState {}

final class AddEmployeeFailure extends AddEmployeeState {
  final String errorMessage;

  AddEmployeeFailure(this.errorMessage);
}
