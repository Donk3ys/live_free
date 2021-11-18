import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:live_free/core/constants.dart';
import 'package:live_free/data_models/saving.dart';
import 'package:live_free/data_models/transaction.dart';
import 'package:live_free/service_locator.dart';
import 'package:loggy/loggy.dart';

import '../core/exception.dart';
import '../core/success.dart';

// const _currentUserKey = 'currentUser';
const _jwtKey = 'jwt';
const _refreshTokenKey = 'refreshToken';
const _transactionHistoryKey = "transactionHistoryKey";
const _savingListKey = "savingKey";
const _themeKey = "theme";

class LocalDataSource with UiLoggy {
  final Box _hiveBox;
  //String _userUuid = "";

  LocalDataSource(Box hiveBox) : _hiveBox = hiveBox;

  // UTIL
/*   Future<void> _getUserUuid() async {
    try {
      _userUuid = Jwt.parseJwt(await jwt)["uuid"] as String;
      // loggy.info("userUuid: $_userUuid");
    } catch (e) {
      loggy.error("_getUserUuid: $e");
    }
  } */

  Future<void> clearLocalStorage() async => _hiveBox.deleteFromDisk();

  // NOTE: theme

  Future<ThemeMode> get themeMode async {
    final theme = await _hiveBox.get(
      _themeKey,
      defaultValue: describeEnum(ThemeMode.system),
    ) as String;
    // loggy.warning(theme);
    if (theme == describeEnum(ThemeMode.system)) return ThemeMode.system;
    return theme == describeEnum(ThemeMode.dark)
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<CacheSuccess> setTheme(String theme) async {
    //loggy.info("[STORING JWT] : $jwt");
    await _hiveBox.put(_themeKey, theme);
    return cacheSuccess;
  }

  // NOTE: json web token

  Future<String> get jwt async {
    // Get jwt
    var jwt = await _hiveBox.get(_jwtKey, defaultValue: "null") as String;

    // Check jwt not null
    if (jwt == "null") {
      throw NoTokenException();
    }

    if (jwt[0] == "'") jwt = jwt.substring(1, jwt.length);
    if (jwt[jwt.length - 1] == "'") jwt = jwt.substring(0, jwt.length - 1);

    // loggy.info("[FETCHED JWT] : $jwt");
    return jwt;
  }

  Future<Success> storeJwt(String jwt) async {
    //loggy.info("[STORING JWT] : $jwt");
    await _hiveBox.put(_jwtKey, jwt);
    return cacheSuccess;
  }

  // NOTE: refresh token

  Future<String> get refreshToken async {
    // Get jwt
    var refreshToken =
        await _hiveBox.get(_refreshTokenKey, defaultValue: "null") as String;

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

  Future<CacheSuccess> storeRefreshToken(String refreshToken) async {
    // loggy.info("[STORING REFRESH TOKEN] : $refreshToken");
    await _hiveBox.put(_refreshTokenKey, refreshToken);
    return cacheSuccess;
  }

  // NOTE: transaction history

  Future<List<Transaction>> get transactionHistory async {
    // await _hiveBox.delete(_transactionHistoryKey);

    final stringList = await _hiveBox.get(
      _transactionHistoryKey,
      defaultValue: "[]",
    ) as String;

    final jsonTransHis = jsonDecode(stringList) as List;
    // loggy.info("[Trans Hist] : $jsonTransHis");

    final transHist = jsonTransHis
        .map((jsonTrans) => Transaction.fromJson(jsonTrans as JsonMap))
        .toList();

    // loggy.info("[Trans Hist] : $transHist");
    return transHist;
  }

  Future<void> _storeTransactionList(List<Transaction> transHistList) async {
    final jsonList =
        jsonEncode(transHistList.map((trans) => trans.toJson()).toList());

    await _hiveBox.put(
      _transactionHistoryKey,
      jsonList,
    );
  }

  Future<CacheSuccess> storeTransaction(
    Transaction transaction,
  ) async {
    loggy.debug(transaction.timestamp);
    final transHistList = await transactionHistory;
    transHistList.add(transaction);

    await _storeTransactionList(transHistList);
    return cacheSuccess;
  }

  Future<CacheSuccess> removeTransaction(
    Transaction transaction,
  ) async {
    final transHistList = await transactionHistory;
    transHistList.remove(transaction);

    await _storeTransactionList(transHistList);
    return cacheSuccess;
  }

  // NOTE: savings

  Future<List<Saving>> get savingList async {
    // await _hiveBox.delete(_savingListKey);

    final stringList = await _hiveBox.get(
      _savingListKey,
      defaultValue: "[]",
    ) as String;

    final jsonSavingList = jsonDecode(stringList) as List;
    // loggy.info("[Saving List] : $jsonSavingList");

    final savingList = jsonSavingList
        .map((jsonSaving) => Saving.fromJson(jsonSaving as JsonMap))
        .toList();

    // loggy.info("[Saving List] : $savingList");
    return savingList;
  }

  Future<void> _storeSavingList(List<Saving> sList) async {
    final jsonList =
        jsonEncode(sList.map((saving) => saving.toJson()).toList());

    await _hiveBox.put(
      _savingListKey,
      jsonList,
    );
  }

  Future<CacheSuccess> storeSaving(
    Saving saving,
  ) async {
    final sList = await savingList;
    sList.add(saving);

    await _storeSavingList(sList);
    return cacheSuccess;
  }

  Future<CacheSuccess> removeSaving(
    Saving saving,
  ) async {
    final sList = await savingList;
    sList.remove(saving);

    await _storeSavingList(sList);
    return cacheSuccess;
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
