import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loggy/loggy.dart';

import '../core/exception.dart';
import '../core/success.dart';

const jwtKey = 'jwt';
const refreshTokenKey = 'refreshToken';
const currentUserKey = 'currentUser';

const themeKey = "theme";

class LocalDataSource with UiLoggy {
  final Box hiveBox;
  //String _userUuid = "";

  LocalDataSource(this.hiveBox);

  // UTIL
/*   Future<void> _getUserUuid() async {
    try {
      _userUuid = Jwt.parseJwt(await jwt)["uuid"] as String;
      // loggy.info("userUuid: $_userUuid");
    } catch (e) {
      loggy.error("_getUserUuid: $e");
    }
  } */

  Future<void> clearLocalStorage() async => hiveBox.deleteFromDisk();

  // THEME
  Future<ThemeMode> get themeMode async {
    final theme = await hiveBox.get(themeKey,
        defaultValue: describeEnum(ThemeMode.system)) as String;
    // loggy.warning(theme);
    if (theme == describeEnum(ThemeMode.system)) return ThemeMode.system;
    return theme == describeEnum(ThemeMode.dark)
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> setTheme(String theme) async {
    //loggy.info("[STORING JWT] : $jwt");
    await hiveBox.put(themeKey, theme);
  }

  // TOKENS
  Future<String> get jwt async {
    // Get jwt
    var jwt = await hiveBox.get(jwtKey, defaultValue: "null") as String;

    // Check jwt not null
    if (jwt == "null") {
      throw NoTokenException();
    }

    if (jwt[0] == "'") jwt = jwt.substring(1, jwt.length);
    if (jwt[jwt.length - 1] == "'") jwt = jwt.substring(0, jwt.length - 1);

    // loggy.info("[FETCHED JWT] : $jwt");
    return jwt;
  }

  Future<String> get refreshToken async {
    // Get jwt
    var refreshToken =
        await hiveBox.get(refreshTokenKey, defaultValue: "null") as String;

    // Check jwt not null
    if (refreshToken == "null") {
      throw NoTokenException();
    }

    if (refreshToken[0] == "'") {
      refreshToken = refreshToken.substring(1, refreshToken.length);
    }
    if (refreshToken[refreshToken.length - 1] == "'") {
      refreshToken = refreshToken.substring(0, refreshToken.length - 1);
    }

    //loggy.info("[FETCHED REFRESH TOKEN] : $refreshToken");
    return refreshToken;
  }

  Future<Success> storeJwt(String jwt) async {
    //loggy.info("[STORING JWT] : $jwt");
    await hiveBox.put(jwtKey, jwt);
    return CacheSuccess();
  }

  Future<Success> storeRefreshToken(String refreshToken) async {
    // loggy.info("[STORING REFRESH TOKEN] : $refreshToken");
    await hiveBox.put(refreshTokenKey, refreshToken);
    return CacheSuccess();
  }

  // USER
//   Future<User> get currentUser async {
//     final userJson =
//         await hiveBox.get(currentUserKey, defaultValue: "null") as String;
//     if (userJson == "null")
//       throw AuthorizationException("No user stored in cache");
//
//     final jsonUser = jsonDecode(userJson);
//     final currentUser = User.fromJson(jsonUser as Map<String, dynamic>);
//
//     if (currentUser.uuid == "-1") {
//       throw AuthorizationException('No user stored in cache');
//     }
//
//     //loggy.info("[FETCHED CURRENT USER] : $currentUser");
//     await Future.delayed(const Duration(seconds: 1));
//     return currentUser;
//   }
//
//   Future<Success> storeCurrentUser(User? user) async {
//     // loggy.info("[STORING CURRENT USER] : $user");
//     String userJson = "null";
//     if (user != null) userJson = jsonEncode(user.toJson());
//     await hiveBox.put(currentUserKey, userJson);
//     // html.window.localStorage[currentUserKey] = userJson; // Web
//
//     return CacheSuccess();
//   }
}
