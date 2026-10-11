// ignore_for_file: unused_local_variable

import 'dart:developer' show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(LoginLoadingState());
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      emit(LoginSuccessState());
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException: ${e.code}');
      emit(LoginFailureState(errorMessage: _mapError(e.code)));
    } catch (e) {
      log('Unexpected login error: $e');
      emit(
        LoginFailureState(
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Login failed. Please try again.';
    }
  }
  // Future<void> loginUser({
  //   required String email,
  //   required String password,
  // }) async {
  //   emit(LoginLoadingState());
  //   try {
  //     final credential = await auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     emit(LoginSuccessState());
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'user-not-found') {
  //       log('No user found for that email.');
  //       emit(LoginFailureState(errorMessage: 'No user found for that email.'));
  //     } else if (e.code == 'wrong-password') {
  //       log('Wrong password provided for that user.');
  //       emit(
  //         LoginFailureState(
  //           errorMessage: 'Wrong password provided for that user.',
  //         ),
  //       );
  //     }
  //   }
  // }
}
