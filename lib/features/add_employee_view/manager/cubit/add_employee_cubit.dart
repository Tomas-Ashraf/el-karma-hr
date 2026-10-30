// ignore_for_file: unused_field

import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/add_employee_view/models/add_employee_model.dart';
import 'package:el_karma_ph/features/employees_view/repos/employees_repo.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'add_employee_state.dart';

class AddEmployeeCubit extends Cubit<AddEmployeeState> {
  AddEmployeeCubit({EmployeesRepo? repo})
    : _repo = repo ?? EmployeesRepo(),
      super(AddEmployeeInitial());

  final EmployeesRepo _repo;

  Future<void> submit(NewEmployee employee) async {
    emit(AddEmployeeLoading());
    try {
      await _repo.addEmployee(employee);
      emit(AddEmployeeSuccess());
    } on EmployeeEmailExistsException {
      emit(AddEmployeeFailure('add_employee.email_exists'));
    } on DeviceIdExistsException {
      emit(AddEmployeeFailure('add_employee.device_exists'));
    } on FirebaseException catch (e) {
      log('Failed to add employee: ${e.code}');
      emit(
        AddEmployeeFailure(
          e.code == 'unavailable'
              ? 'error.no_internet'
              : 'add_employee.save_failed',
        ),
      );
    } catch (e) {
      log('Unexpected error adding employee: $e');
      emit(AddEmployeeFailure('add_employee.save_failed'));
    }
  }
}
