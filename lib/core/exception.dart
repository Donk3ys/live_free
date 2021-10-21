class AuthorizationException implements Exception {
  final String message;
  AuthorizationException(this.message);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => message;
}

class RemoteDataSourceException implements Exception {
  final String message;
  final String errorMessage;
  RemoteDataSourceException(this.message, {this.errorMessage = ""});

  @override
  String toString() => message;
}

class FromJsonException implements Exception {
  final String message;
  FromJsonException(this.message);

  @override
  String toString() => message;
}

class NoTokenException implements Exception {}
