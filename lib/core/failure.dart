import 'constants.dart';

class Failure {}

class AuthFailure extends Failure {
  final String message;
  AuthFailure(this.message);

  @override
  String toString() => message;
}

class OfflineFailure extends Failure {
  final String message = kMessageOfflineError;

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  final String message;
  ServerFailure(this.message);

  @override
  String toString() => message;
}

class CacheFailure extends Failure {
  final String message;
  CacheFailure(this.message);

  @override
  String toString() => message;
}

class FormatFailure extends Failure {
  final String message;
  FormatFailure(this.message);

  @override
  String toString() => message;
}

class NoTokenFailure extends Failure {}

