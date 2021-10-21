import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

mixin UtilCore {
  static String getDateTimeDiffCompact(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 10) {
      return "Just now";
    } else if (difference.inMinutes < 1) {
      return "${difference.inSeconds}s ago";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 365) {
      return "${difference.inDays}d ago";
    } else {
      return "${(difference.inDays / 365).floor()}y ago";
    }
  }
}

extension CapExtension on String {
  String get capitalizeFirst =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String get capitalizeFirstOfEach => replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.capitalizeFirst)
      .join(" ");
  String get camelCaseToString => replaceAllMapped(
        RegExp('(?<=[a-z])[A-Z]'),
        (Match m) => ' ${m.group(0) ?? ""}',
      );
}

String formatNumAmount(num amount) {
  var formatAmount = amount;
  if (amount is int) formatAmount = amount / 100;
  return CurrencyTextInputFormatter(symbol: "R ")
      .format(formatAmount.toStringAsFixed(2));
}

String formatStringAmount(String amount) =>
    CurrencyTextInputFormatter(symbol: "R ").format(amount);
