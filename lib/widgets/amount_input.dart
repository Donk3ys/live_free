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

class AmountSelector extends StatefulWidget {
  final Function(int) onSubmitted;
  final Function() onBackButtonPressed;
  final String title;
  final Color color;

  const AmountSelector({
    Key? key,
    required this.onSubmitted,
    required this.onBackButtonPressed,
    required this.title,
    required this.color,
  }) : super(key: key);
  @override
  State<AmountSelector> createState() => _AmountSelectorState();
}

class _AmountSelectorState extends State<AmountSelector> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => widget.onBackButtonPressed(),
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48.0),
              ],
            ),
            const SizedBox(height: 12.0),
            AmountKeypad(
              onSubmitted: widget.onSubmitted,
              textColor: widget.color,
            ),
          ],
        ),
      ),
    );
  }
}
