import 'package:el_karma_ph/features/no_internet_view/manager/cubit/connection_cubit.dart';
import 'package:el_karma_ph/features/no_internet_view/presentation/view/no_internet_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectionWrapper extends StatelessWidget {
  const ConnectionWrapper({super.key, required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionCubit, ConnectionStatus>(
      builder: (context, status) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ?child,
            if (status == ConnectionStatus.offline) const NoInternetView(),
          ],
        );
      },
    );
  }
}
