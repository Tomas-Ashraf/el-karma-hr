import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum ConnectionStatus { online, offline }

class ConnectionCubit extends Cubit<ConnectionStatus> {
  ConnectionCubit({InternetConnection? connection})
    : _connection = connection ?? InternetConnection(),
      super(ConnectionStatus.online) {
    _subscription = _connection.onStatusChange.listen((status) {
      emit(
        status == InternetStatus.connected
            ? ConnectionStatus.online
            : ConnectionStatus.offline,
      );
    });
    checkNow();
  }

  final InternetConnection _connection;
  late final StreamSubscription<InternetStatus> _subscription;

  Future<bool> checkNow() async {
    final online = await _connection.hasInternetAccess;
    if (!isClosed) {
      emit(online ? ConnectionStatus.online : ConnectionStatus.offline);
    }
    return online;
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
