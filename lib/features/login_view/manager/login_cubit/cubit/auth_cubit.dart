// ignore_for_file: unused_local_variable

import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/features/login_view/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final FirebaseAuth firebaseInstance = FirebaseAuth.instance;
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    emit(AuthLoadingState());
    try {
      await firebaseInstance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await getUserInfo(email: trimmedEmail);
      emit(AuthSuccessState());
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException: ${e.code}');
      emit(AuthFailureState(errorMessage: _mapError(e.code)));
    } catch (e) {
      log('Unexpected login error: $e');
      emit(AuthFailureState(errorMessage: 'error.generic'));
    }
  }

  Future<bool> checkAccountStatus({required String? email}) async {
    emit(AuthLoadingState());

    try {
      if (email == null || email.isEmpty) {
        emit(AuthFailureState(errorMessage: 'error.user_not_found'));
        return false;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        emit(AuthFailureState(errorMessage: 'error.user_not_found'));
        return false;
      }

      final status = snapshot.docs.first.data()['status'];

      if (status == 'inactive') {
        emit(AuthInitial());
        return false;
      }

      return true;
    } catch (e) {
      log('Error checking account status: $e');

      emit(AuthFailureState(errorMessage: 'error.generic'));

      return false;
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'error.invalid_credentials';
      case 'invalid-email':
        return 'error.invalid_email';
      case 'user-disabled':
        return 'error.user_disabled';
      case 'too-many-requests':
        return 'error.too_many_requests';
      case 'network-request-failed':
        return 'error.no_internet';
      default:
        return 'error.login_failed';
    }
  }

  Future<void> getUserInfo({required String email}) async {
    final prefs = await SharedPreferences.getInstance();

    UserModel userModel;
    final db = FirebaseFirestore.instance;
    final snapshot = await db
        .collection(kUsersCollection)
        .where('email', isEqualTo: email)
        .get();
    userModel = UserModel.fromDocument(snapshot.docs.first.data());
    await prefs.setString('userName', userModel.name);
    await prefs.setString('userEmail', userModel.email);
    await prefs.setString('userJob', userModel.job);
    await prefs.setString('userStatus', userModel.status);
    await prefs.setString('userType', userModel.userType);
    await prefs.setBool('loggedIn', true);
    log('UserName:${prefs.getString('userName')}');
    log('UserEmail:${prefs.getString('userEmail')}');
    log('UserJob:${prefs.getString('userJob')}');
    log('UserStatus:${prefs.getString('userStatus')}');
    log('UserType:${prefs.getString('userType')}');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);
    await prefs.setString('userName', '');
    await prefs.setString('userEmail', '');
    await prefs.setString('userJob', '');
    await prefs.setString('userStatus', '');
    await prefs.setString('userType', '');
    bool? isLogged = prefs.getBool('loggedIn');
    log('IsLogged: $isLogged');
    await FirebaseAuth.instance.signOut();
  }
}
