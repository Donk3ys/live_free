abstract class Success {}

class ServerSuccess<Type> extends Success {
  final String jwt;
  final String refreshToken;
  final Type? object;

  ServerSuccess({
    this.jwt = "",
    this.refreshToken = "",
    this.object,
  });

  @override
  String toString() {
    return '$object';
  }
}

class CacheSuccess extends Success {
  final String? message;

  CacheSuccess({this.message});

  @override
  String toString() {
    return "CacheSuccess: $message";
  }
}
