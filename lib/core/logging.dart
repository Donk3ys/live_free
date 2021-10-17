import 'package:loggy/loggy.dart';

class CustomLogPrinter extends LoggyPrinter {
  final prettyPrinter = const PrettyPrinter();
  CustomLogPrinter();

  @override
  void onLog(LogRecord record) {
    final className = record.loggerName;
    final level = record.level;
    final color = prettyPrinter.levelColor(level);
    final emoji = prettyPrinter.levelPrefix(level);
    final message = record.message;
    final trace = record.stackTrace;
    if (trace != null) {
      final frames = trace.toString().split("\n");
      final max = frames.length >= 4 ? 4 : frames.length;
      print(color!("$level $emoji - $className\n$message\n"));
      int i = 0;
      while (i <= max) {
        print(color(frames[i]));
        i++;
      }
    } else {
      print(color!("$level $emoji - $className\n$message\n"));
    }
  }
}
