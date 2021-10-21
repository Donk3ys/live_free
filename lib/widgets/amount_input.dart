import 'package:flutter/material.dart';
import 'package:live_free/core/util_core.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';

class AmountKeypad extends StatefulWidget {
  final Function(int) onSubmitted;
  final Color textColor;
  const AmountKeypad({
    Key? key,
    required this.onSubmitted,
    required this.textColor,
  }) : super(key: key);

  @override
  _AmountKeypadState createState() => _AmountKeypadState();
}

class _AmountKeypadState extends State<AmountKeypad> {
  final _amountStyle = const TextStyle(fontSize: 30.0);
  String _amount = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _amount.isNotEmpty ? formatStringAmount(_amount) : "R 0.00",
          style: _amountStyle,
        ),
        NumericKeyboard(
          onKeyboardTap: (number) => setState(() {
            _amount = _amount + number;
            _amount = formatStringAmount(_amount);
          }),
          textColor: widget.textColor,
          rightButtonFn: () {
            setState(() {
              _amount = _amount.replaceAll(",", "");
              final amount = double.tryParse(
                    _amount.substring(1, _amount.length - 1),
                  ) ??
                  0;
              if (amount == 0.0) {
              } else {
                widget.onSubmitted((amount * 100).round());
              }
            });
          },
          leftButtonFn: () {
            setState(() {
              _amount = _amount.substring(0, _amount.length - 1);
              _amount = formatStringAmount(_amount);
            });
          },
          rightIcon: _amount.isNotEmpty
              ? Icon(
                  Icons.check,
                  color: widget.textColor,
                )
              : null,
          leftIcon: Icon(
            Icons.backspace,
            color: widget.textColor,
          ),
        ),
      ],
    );
  }
}
