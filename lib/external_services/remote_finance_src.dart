import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart';

import 'utils_external_srv.dart';

class RemoteFinanceSource {
  final Client http;
  final String serverUrl;

  RemoteFinanceSource(this.http, this.serverUrl);

  Future<Unit> fetchSportfolio(String jwt, String userUuid) async {
    final uri = Uri.parse("$serverUrl/fetchSportfolio.php?id=$userUuid");
    //loggy.debug(uri);

    // Send post request
//     final response = await http.get(
//       uri,
//       headers: {"jwt": jwt},
//     ).timeout(kTimeOutDuration);

    // MOCK RESPONSE
    await Future.delayed(const Duration(milliseconds: 700));
    final response = Response('{"Success"}', 200); // Good
//     final response = Response(
//       '{"Message":"Remote Data Error", "Error":"Detailed message sent to console"}',
//       500,
    // ); // Error
    // throw TimeoutException("Time out thrown");

    // DEBUG -> Log url path & status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == 200) {
      // final bodyJson = jsonDecode(response.body);
      return unit;
    }

    throw ExternalServiceUtil.handleResponse(response: response);
  }
}
