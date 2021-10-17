import 'package:flutter/material.dart';

import '../core/constants.dart';

enum SnackBarColor { success, warning, error }
const kErrorTextColor = Colors.white;

mixin InfoSnackBar {
  static Future<void> showSuccess(
    BuildContext context,
    String message, {
    SnackBarColor color = SnackBarColor.success,
    String? title,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      await _create(color: color, message: message, title: title),
    );
  }

  static Future<void> showWarning(
    BuildContext context,
    String message, {
    SnackBarColor color = SnackBarColor.warning,
    String? title,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      await _create(color: color, message: message, title: title),
    );
  }

  static Future<void> showError(
    BuildContext context,
    String message, {
    SnackBarColor color = SnackBarColor.error,
    String? title,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      await _create(color: color, message: message, title: title),
    );
  }

  static Future<SnackBar> _create({
    SnackBarColor color = SnackBarColor.success,
    required String message,
    String? title,
  }) async {
    return SnackBar(
      duration: const Duration(seconds: 10),
      backgroundColor: _getColor(color),
      content: title == null
          ? Text(
              message,
              style: const TextStyle(color: kErrorTextColor),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kErrorTextColor,
                  ),
                ),
                Text(message)
              ],
            ),
      action: SnackBarAction(
        textColor: kErrorTextColor,
        label: 'ok',
        onPressed: () {},
      ),
    );
  }

  static Color _getColor(SnackBarColor color) {
    switch (color) {
      case SnackBarColor.success:
        {
          return kColorSuccess;
        }

      case SnackBarColor.warning:
        {
          return kColorWarning;
        }

      case SnackBarColor.error:
        {
          return kColorError;
        }

      default:
        {
          return kColorSuccess;
        }
    }
  }
}

