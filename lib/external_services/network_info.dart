import 'package:internet_connection_checker/internet_connection_checker.dart';

// MOBILE
class NetworkInfo {
  final InternetConnectionChecker internetConnectionChecker;
  NetworkInfo(this.internetConnectionChecker);
  Future<bool> get hasInternetConnection =>
      internetConnectionChecker.hasConnection;
}
