import 'dart:developer' show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'reset_pass_state.dart';

class ResetPassCubit extends Cubit<ResetPassState> {
  ResetPassCubit() : super(ResetPassInitial());
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<String?> sendPasswordResetEmail({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
      log('Password reset email sent to $email');
      emit(ResetPassSuccessState());
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          emit(ResetPassFailureState(errorMessage: 'User not found.'));
          return null;
        case 'invalid-email':
          emit(
            ResetPassFailureState(
              errorMessage: 'The email address is not valid.',
            ),
          );
          return null;
        case 'too-many-requests':
          emit(
            ResetPassFailureState(
              errorMessage: 'Too many attempts. Please try again later.',
            ),
          );
          return null;
        case 'network-request-failed':
          emit(
            ResetPassFailureState(
              errorMessage:
                  'No internet connection. Please check your network.',
            ),
          );
          return null;
        default:
          emit(
            ResetPassFailureState(
              errorMessage: 'Something went wrong. Please try again.',
            ),
          );
          return null;
      }
    } catch (_) {
      emit(
        ResetPassFailureState(
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
      return null;
    }
  }
}
