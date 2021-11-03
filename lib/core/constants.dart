import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'failure.dart';

const kVersion = 'Powered by Donk3y [0.0.0]'; // 16:40 14 Oct 2021

// TYPE DEF
typedef JsonMap = Map<String, dynamic>;
typedef FailOr<R> = Future<Either<Failure, R>>;

// NETWORKING
const kTimeOutDuration = Duration(seconds: 30);

// COLORS
//const kColorBackgroundDark = Color(0xff000000);
const kColorBackgroundDark = Colors.black87;
const kColorBackgroundLight = Color(0xffe8e8e8);

//const kColorPrimary = Color(0xff383838);

const kColorButton = Color(0xff383838);
const kColorCardDark = Color(0xff1f1f1f);
const kColorCardLight = Color(0xfff8f8f8);

const kColorAccent = Colors.amberAccent;

const kColorAdd = Colors.green;
const kColorRemove = Colors.red;
const kColorUpdate = Colors.blue;

const kColorIncome = Colors.green;
const kColorExpence = Colors.redAccent;
const kColorSaving = Colors.blue;

const kColorSuccess = Colors.green;
// const kColorSuccess = Color(0xff89b482);
const kColorError = Color(0xffc91c1c);
// const kColorError = Color(0xffea6962);
const kColorWarning = Color(0xffcc973d);

const kColorTextContent = Color(0xfff9f5d7);
const kColorSecondaryText = Color(0xffa8a8a8);

// STYLES
const kTextStyleHeading = TextStyle(
  fontSize: 26,
  fontWeight: FontWeight.bold,
);

const kTextStyleSubHeading = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

const kTextStyleMedium = TextStyle(
    // color: kColorSecondaryText
    );

const kTextStyleSmall = TextStyle(
  fontSize: 12,
);

const kTextStyleSmallSecondary = TextStyle(
  fontSize: 12,
  color: kColorSecondaryText,
);

const kTextStyleMessage = TextStyle(
  fontSize: 16,
  // color: kColorSecondaryText
);
const kTextStyleUserName = TextStyle(
  fontWeight: FontWeight.bold,
  // color: kColorSecondaryText
);
const kTextStyleCreatedAt = TextStyle(
  fontSize: 10,
  color: kColorAccent,
  fontWeight: FontWeight.bold,
);

const kPaginationFeed = 3;
const kPaginationExplorer = 3;

const kCardWidth = 250.0;
const kCardHeight = 310.0;

// const kCardImageHeight = 200.0;
const kCardImageHeight = 180.0;

const kDrawerMenuTilePadding =
    EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0);
const kDrawerMenuTileHeight = 40.0;
const kDrawerWidth = 230.0;
const kDrawerDivider = Divider(
  height: 26.0,
  thickness: 2,
  indent: 18,
  endIndent: 18,
  color: kColorBackgroundDark,
);

/// SCREEN BREAK POINTS
const kTabletBreakPoint = 768.0;
const kMobileBreakPoint = 530.0;

/// MESSAGES
const kPasswordNotLongEnough = 'Password must be at least 6 characters long';
const kPasswordMissMatch = "Passwords don't match";

const kFieldNotEnteredMessage = 'Field cannot be left empty';
const kConnectionErrorMessage =
    "Connection error, please check your device has internet connection";

const kMessageOfflineError =
    'Could not reach server! Please check internet connection.';
const kMessageAuthError = 'Authorization Error';
const kMessageUnexpectedCacheError = 'Unexpected Cache Error';
const kMessageUnexpectedFormatError = 'Unexpected Format Error';
const kMessageUnexpectedServerError = 'Unexpected Server Error';

const kMessageEmailUpdateSuccess = 'Email update success';
const kMessagePasswordUpdateSuccess = 'Password update success';
const kMessageUsernameUpdateSuccess = 'Username update success';

const kMessagePasswordResetRequestEmailError = "[ERROR] Password Reset Request";
const kMessagePasswordResetUpdateSuccess = 'Password reset email sent success';

const kNullDateString = "1970-01-01T00:00:00";

/// Error Messages / Codes
const kXMLHttpRequestError = "XMLHttpRequest";

/// Support Email
final Uri kSupportEmailLaunchUri = Uri(
  scheme: 'mailto',
  path: 'support@findgo.co.za',
  query: 'subject=FindGo Support',
);
