import 'package:flutter/material.dart';

import '../external_services/network_info.dart';

enum _NetworkViewState { online, offline }

class NetworkViewModel extends ChangeNotifier {
  NetworkInfo networkInfo;
  NetworkViewModel({
    required this.networkInfo,
  });

  _NetworkViewState _state = _NetworkViewState.online;
  _NetworkViewState get state => _state;
  void _setState(_NetworkViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  bool get isOnline => _state == _NetworkViewState.online;
  bool get isOffline => _state == _NetworkViewState.offline;

  Future<void> checkNetworkStatus() async => _setState(
        await networkInfo.hasInternetConnection
            ? _NetworkViewState.online
            : _NetworkViewState.offline,
      );
  Future<void> streamNetworkStatus() async {
    do {
      await checkNetworkStatus();
      // loggy.debug(state);
      await Future.delayed(const Duration(seconds: 5));
    } while (isOffline);
  }
}

