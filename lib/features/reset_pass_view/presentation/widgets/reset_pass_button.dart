import 'package:el_karma_ph/constants.dart';
import 'package:el_karma_ph/core/utils/styles.dart';
import 'package:el_karma_ph/core/widgets/button_widget.dart';
import 'package:el_karma_ph/features/reset_pass_view/manager/cubit/reset_pass_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPassButton extends StatelessWidget {
  const ResetPassButton({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPassCubit, ResetPassState>(
      builder: (context, state) {
        final isLoading = state is ResetPassLoadingState;
        return ButtonWidget(
          width: double.infinity,
          height: 52,
          onPressed: () {
            if (isLoading) return;
            BlocProvider.of<ResetPassCubit>(context)
                .sendPasswordResetEmail(email: email);
          },
          backgroundColor: kPrimaryBlue,
          foregroundColor: Colors.white,
          text: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text('Send Reset Link', style: Styles.textStyle16),
        );
      },
    );
  }
}
