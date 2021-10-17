import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:loggy/loggy.dart';

import '../core/constants.dart';
import '../core/exception.dart';

final loggy = Loggy("External Data Source");

mixin ExternalServiceUtil {
  static Exception handleResponse({required Response response}) {
    if (response.body.isEmpty) {
      return RemoteDataSourceException(kMessageUnexpectedServerError);
    }
    final jsonResp = json.decode(response.body);
    final message =
        jsonResp["Message"] as String? ?? kMessageUnexpectedServerError;
    final errorMsg = jsonResp["Error"] as String?;
    if (response.statusCode == 401) return AuthorizationException(message);
    if (response.statusCode == 502) return const SocketException("Bad Gateway");
    return RemoteDataSourceException(message, errorMessage: errorMsg ?? "");
  }

  static void printResponseCode(
    Uri uri,
    int responseCode, {
    StackTrace? trace,
  }) {
    loggy.info("$uri -> Response Code: $responseCode", null, trace);
  }
}
