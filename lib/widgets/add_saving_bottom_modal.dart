import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_free/core/util_core.dart';
import 'package:live_free/data_models/saving.dart';
import 'package:live_free/service_locator.dart';
import 'package:live_free/view_models/saving_vm.dart';
import 'package:live_free/widgets/amount_input.dart';

import '../core/constants.dart';

final SavingViewModel _savingVm = sl();

class AddSavingBottomModal extends StatefulWidget {
  @override
  State<AddSavingBottomModal> createState() => _AddSavingBottomModalState();
}

class _AddSavingBottomModalState extends State<AddSavingBottomModal> {
  String _selectedName = "";
  int _selectedAmount = 0;

  @override
  void initState() {
    // Do after init build (So context will have scaffold for snackbar errors)
    WidgetsBinding.instance!.addPostFrameCallback((_) async {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      // color: Colors.amber,
      child: Column(
        children: [
          const SizedBox(
            width: 100.0,
            child: Divider(
              color: Colors.white,
              thickness: 2.0,
              height: 30.0,
            ),
          ),
          Expanded(
            child: _currentWidget(),
          ),
        ],
      ),
    );
  }

  Widget _currentWidget() {
    if (_selectedName.isEmpty) {
      return _SavingNameInput(
        onNameCreated: (name) => setState(() => _selectedName = name),
      );
    } else if (_selectedAmount == 0) {
      return _SavingAmountSelector(
        onBackButtonPressed: () => setState(() => _selectedName = ""),
        onSubmitted: (amount) => setState(() => _selectedAmount = amount),
      );
    } else {
      return _SavingSummary(
        onNameSelected: () => setState(() => _selectedName = ""),
        onAmountSelect: () => setState(() => _selectedAmount = 0),
        name: _selectedName,
        amount: _selectedAmount,
      );
    }
  }
}

class _SavingNameInput extends StatefulWidget {
  final Function(String) onNameCreated;

  const _SavingNameInput({
    Key? key,
    required this.onNameCreated,
  }) : super(key: key);

  @override
  State<_SavingNameInput> createState() => _SavingNameInputState();
}

class _SavingNameInputState extends State<_SavingNameInput> {
  final _nameTextController = TextEditingController();

  @override
  void dispose() {
    _nameTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // Do after init build (So context will have scaffold for snackbar errors)
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _savingVm.fetchSavingList(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        watch(savingVmProvider);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text(
                "Add Savings Name",
                style: kTextStyleSubHeading,
              ),
              const SizedBox(height: 12.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    onSubmitted: (_) =>
                        widget.onNameCreated(_nameTextController.text.trim()),
                    style: const TextStyle(fontSize: 26.0),
                    decoration: const InputDecoration(
                      hintText: "Primary Bank",
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    controller: _nameTextController,
                    autofocus: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SavingAmountSelector extends StatefulWidget {
  final Function(int) onSubmitted;
  final Function() onBackButtonPressed;

  const _SavingAmountSelector({
    Key? key,
    required this.onSubmitted,
    required this.onBackButtonPressed,
  }) : super(key: key);
  @override
  State<_SavingAmountSelector> createState() => _SavingAmountSelectorState();
}

class _SavingAmountSelectorState extends State<_SavingAmountSelector> {
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
                const Expanded(
                  child: Text(
                    "How much?",
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: kColorSaving,
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
              textColor: kColorSaving,
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingSummary extends StatefulWidget {
  final Function() onNameSelected;
  final String name;
  final Function() onAmountSelect;
  final int amount;

  const _SavingSummary({
    Key? key,
    required this.amount,
    required this.onAmountSelect,
    required this.onNameSelected,
    required this.name,
  }) : super(key: key);

  @override
  State<_SavingSummary> createState() => _SavingSummaryState();
}

class _SavingSummaryState extends State<_SavingSummary> {
  static const _kLableStyle = TextStyle(fontSize: 18.0);
  static const _kTransactionItemStyle = TextStyle(fontSize: 22.0);
  static const _kLableWidth = 30.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.65;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 12.0),
          const Text(
            "Add Saving",
            style: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
              // color: kColorSaving,
            ),
          ),
          const SizedBox(height: 32.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                "Name",
                style: _kLableStyle,
                textAlign: TextAlign.end,
              ),
              const SizedBox(width: _kLableWidth),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () => widget.onNameSelected(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.name,
                      style: _kTransactionItemStyle,
                      // textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                "Amount",
                style: _kLableStyle,
                textAlign: TextAlign.end,
              ),
              const SizedBox(width: _kLableWidth),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () => widget.onAmountSelect(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      formatNumAmount(widget.amount),
                      style: _kTransactionItemStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 42.0),
          Consumer(
            builder: (context, watch, child) {
              watch(savingVmProvider);
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                  onPrimary: Colors.black87,
                ),
                onPressed: () async {
                  final success = await _savingVm.addSaving(
                    context,
                    Saving(
                      uuid: "",
                      name: widget.name,
                      amount: widget.amount,
                    ),
                  );

                  if (!success) return;
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Save",
                    style: TextStyle(fontSize: 30.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
