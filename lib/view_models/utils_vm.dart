import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';

import '../core/constants.dart';
import '../core/failure.dart';
import '../main.dart';
import '../widgets/snackbar.dart';

final failureLogger = Loggy("Failure");

mixin ViewModelUtil {
  static void _logFailure(Failure f) {
    failureLogger.debug('type:\t${f.runtimeType}\nmessage:\t$f');
  }

  static Future<void> handleFailure({
    required BuildContext context,
    required Failure failure,
    bool logout = false,
  }) async {
    String message = failure.toString();
    _logFailure(failure);

    // Check if failure is auth failure
    if (logout) {
      // If no user stored
      // context.read(authVMProvider).logout();
      if (failure is! NoTokenFailure) InfoSnackBar.showError(context, message);
      return;
    }
    if (failure is AuthFailure) {
      if (message != kMessageOfflineError) {
        InfoSnackBar.showError(context, message);
      }
      return;
    }

    // Check if failure could be offline failure due to timeout
    if (failure.toString().contains(kXMLHttpRequestError) ||
        failure is OfflineFailure) {
      InfoSnackBar.showError(context, kConnectionErrorMessage);
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
    // if (failure is ServerFailure) message = kMessageUnexpectedServerError;

    // Show Error message
    InfoSnackBar.showError(context, message);
  }
}
