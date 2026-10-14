import 'dart:developer' show log;

import 'package:el_karma_ph/features/login_view/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());

  Future<UserModel> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName') ?? '';
    final userRole = prefs.getString('userJob') ?? '';
    emit(GetUserDataSuccess());
    log('D UserRole: $userRole');
    return UserModel(
      name: userName,
      email: '',
      job: userRole,
      status: '',
      userType: '',
    );
  }
}
