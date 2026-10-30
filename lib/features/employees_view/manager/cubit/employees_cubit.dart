import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/employees_view/repos/employees_repo.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'employees_state.dart';

class EmployeesCubit extends Cubit<EmployeesState> {
  EmployeesCubit({EmployeesRepo? repo})
    : _repo = repo ?? EmployeesRepo(),
      super(EmployeesInitial());

  final EmployeesRepo _repo;

  Future<void> fetchEmployees({bool silent = false}) async {
    if (!silent) emit(EmployeesLoading());
    try {
      final employees = await _repo.getEmployees();
      emit(EmployeesSuccess(employees));
    } on FirebaseException catch (e) {
      log('Failed to load employees: ${e.code}');
      emit(
        EmployeesFailure(
          e.code == 'unavailable'
              ? 'error.no_internet'
              : 'employees.load_failed',
        ),
      );
    } catch (e) {
      log('Unexpected error loading employees: $e');
      emit(EmployeesFailure('employees.load_failed'));
    }
  }

  Future<String?> deleteEmployee(String id) async {
    try {
      await _repo.deleteEmployee(id);
      await fetchEmployees(silent: true);
      return null;
    } on FirebaseException catch (e) {
      log('Failed to delete employee: ${e.code}');
      return e.code == 'unavailable'
          ? 'error.no_internet'
          : 'employees.delete_failed';
    } catch (e) {
      log('Unexpected error deleting employee: $e');
      return 'employees.delete_failed';
    }
  }
}
