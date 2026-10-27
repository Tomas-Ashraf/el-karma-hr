import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/features/employee_details_view/manager/cubit/employee_details_state.dart';
import 'package:el_karma_ph/features/employees_view/models/employee_model.dart';
import 'package:el_karma_ph/features/employees_view/repos/employees_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeDetailsCubit extends Cubit<EmployeeDetailsState> {
  EmployeeDetailsCubit(EmployeeModel employee, {EmployeesRepo? repo})
    : _repo = repo ?? EmployeesRepo(),
      super(EmployeeDetailsState(employee: employee));

  final EmployeesRepo _repo;

  Future<void> update(Map<String, dynamic> data) async {
    if (state.status == EmployeeDetailsStatus.saving) return;
    emit(state.copyWith(status: EmployeeDetailsStatus.saving));

    try {
      await _repo.updateEmployee(state.employee.id, data);
      final updated = EmployeeModel.fromDocument(state.employee.id, {
        ...state.employee.toMap(),
        ...data,
      });
      emit(
        EmployeeDetailsState(
          employee: updated,
          status: EmployeeDetailsStatus.saved,
        ),
      );
    } on DeviceIdExistsException {
      emit(
        state.copyWith(
          status: EmployeeDetailsStatus.failure,
          message: 'add_employee.device_exists',
        ),
      );
    } on FirebaseException catch (e) {
      log('Failed to update employee: ${e.code}');
      emit(
        state.copyWith(
          status: EmployeeDetailsStatus.failure,
          message: e.code == 'unavailable'
              ? 'error.no_internet'
              : 'employee_details.update_failed',
        ),
      );
    } catch (e) {
      log('Unexpected error updating employee: $e');
      emit(
        state.copyWith(
          status: EmployeeDetailsStatus.failure,
          message: 'employee_details.update_failed',
        ),
      );
    }
  }
}
