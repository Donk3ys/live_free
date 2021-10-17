import 'dart:async';
import 'dart:io';

import 'package:loggy/loggy.dart';

import '../core/constants.dart';
import '../core/exception.dart';
import '../core/failure.dart';

final exceptionLogger = Loggy("Exception");

mixin RepoUtil {
  static void _logError(StackTrace? trace, Object e) {
    final message = e.toString();
    String errorMessage = "";
    if (e is NoTokenException) return;
    if (e is RemoteDataSourceException && e.errorMessage.isNotEmpty) {
      errorMessage = "\nerror:\t${e.errorMessage}";
    }
    exceptionLogger.error(
      'type:\t${e.runtimeType}\nmessage:\t$message$errorMessage',
      null,
      trace,
    );
  }

  static Future<Failure> handleException(Object err, StackTrace trace) async {
    final message = err.toString();
    _logError(trace, err);
    if (err is Error) return FormatFailure(err.toString());

    switch (err.runtimeType) {
      case AuthorizationException:
        {
          return AuthFailure(message);
        }
      case CacheException:
        {
          return CacheFailure(message);
        }
      case FormatException:
        {
          return FormatFailure(kMessageUnexpectedServerError);
        }
      case FromJsonException:
        {
          return FormatFailure(kMessageUnexpectedServerError);
        }
      case NoTokenException:
        {
          return NoTokenFailure();
        }
      case SocketException:
        {
          return OfflineFailure();
        }
      case TimeoutException:
        {
          return OfflineFailure();
        }

      default:
        return ServerFailure(message);
    }
  }
}
