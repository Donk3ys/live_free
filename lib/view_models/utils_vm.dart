import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_free/core/exception.dart';
import 'package:live_free/service_locator.dart';
import 'package:loggy/loggy.dart';

import '../core/constants.dart';
import '../core/failure.dart';
import '../widgets/snackbar.dart';

final exceptionLogger = Loggy("Exception");
final failureLogger = Loggy("Failure");

mixin ViewModelUtil {
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

  // static Future<Failure> handleException(
  static Future<void> handleException(
    Object err,
    StackTrace trace, {
    required BuildContext context,
    bool logout = false,
    bool showErrorSnackbar = true,
  }) async {
    final message = err.toString();
    _logError(trace, message);

    void _handleOfflineError() {
      if (showErrorSnackbar) {
        InfoSnackBar.showError(context, kConnectionErrorMessage);
      }
      final networkVM = context.read(networkVMProvider);
      networkVM.streamNetworkStatus();
      return;
    }

    if (message.contains(kXMLHttpRequestError)) _handleOfflineError();
    if (err is Error && showErrorSnackbar) {
      InfoSnackBar.showError(context, kMessageUnexpectedFormatError);
      return;
    }
    // if (err is Error) return FormatFailure(err.toString());
    switch (err.runtimeType) {
      case AuthorizationException:
        {
          if (message != kMessageOfflineError && showErrorSnackbar) {
            InfoSnackBar.showError(context, message);
          }
          // return AuthFailure(message);
          break;
        }
      case CacheException:
        {
          if (showErrorSnackbar) {
            InfoSnackBar.showError(context, kMessageUnexpectedCacheError);
          }
          // return CacheFailure(message);
          break;
        }
      case FormatException:
        {
          if (showErrorSnackbar) {
            InfoSnackBar.showError(context, kMessageUnexpectedFormatError);
          }
          // return FormatFailure(kMessageUnexpectedServerError);
          break;
        }
      case FromJsonException:
        {
          if (showErrorSnackbar) {
            InfoSnackBar.showError(context, kMessageUnexpectedFormatError);
          }
          // return FormatFailure(kMessageUnexpectedServerError);
          break;
        }
      case NoTokenException:
        {
          if (logout) {
            if (showErrorSnackbar) {
              InfoSnackBar.showError(context, message);
            }
            // TODO: put back if auth enabled
            // If no user stored
            // context.read(authVMProvider).logout();
          }
          // return NoTokenFailure();
          break;
        }
      case SocketException:
        {
          _handleOfflineError();
          // return OfflineFailure();
          break;
        }
      case TimeoutException:
        {
          _handleOfflineError();
          // return OfflineFailure();
          break;
        }

      default:
        {
          if (showErrorSnackbar) {
            InfoSnackBar.showError(context, kMessageUnexpectedServerError);
          }
          // return ServerFailure(message);
        }
    }
  }

  static void _logFailure(Failure f) {
    failureLogger.debug('type:\t${f.runtimeType}\nmessage:\t$f');
  }

  static Future<void> handleFailure({
    required BuildContext context,
    required Failure failure,
    bool logout = false,
    bool showErrorSnackbar = true,
  }) async {
    String message = failure.toString();
    _logFailure(failure);

    // Check if failure is auth failure
    if (logout) {
      // If no user stored
      // context.read(authVMProvider).logout();
      if (failure is! NoTokenFailure && showErrorSnackbar) {
        InfoSnackBar.showError(context, message);
      }
      return;
    }
    if (failure is AuthFailure) {
      if (message != kMessageOfflineError && showErrorSnackbar) {
        InfoSnackBar.showError(context, message);
      }
      return;
    }

    // Check if failure could be offline failure due to timeout
    if (failure.toString().contains(kXMLHttpRequestError) ||
        failure is OfflineFailure) {
      if (showErrorSnackbar) {
        InfoSnackBar.showError(context, kConnectionErrorMessage);
      }
      final networkVM = context.read(networkVMProvider);
      networkVM.streamNetworkStatus();
      return;
    }

    // Check if error is cache failure or due to json parsing
    if (failure is CacheFailure) {
      message = kMessageUnexpectedCacheError;
    }
    if (failure is FormatFailure) {
      message = kMessageUnexpectedFormatError;
    }
    if (failure is NoTokenFailure) return;

    // Show Error message
    if (showErrorSnackbar) InfoSnackBar.showError(context, message);
  }
}
