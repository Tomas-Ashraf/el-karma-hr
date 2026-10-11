part of 'reset_pass_cubit.dart';

sealed class ResetPassState {}

final class ResetPassInitial extends ResetPassState {}

final class ResetPassLoadingState extends ResetPassState {}

final class ResetPassSuccessState extends ResetPassState {}

final class ResetPassFailureState extends ResetPassState {
  final String errorMessage;

  ResetPassFailureState({required this.errorMessage});
}
