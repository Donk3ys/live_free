import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_free/core/util_core.dart';
import 'package:live_free/data_models/transaction.dart';
import 'package:live_free/service_locator.dart';
import 'package:live_free/view_models/transaction_vm.dart';
import 'package:live_free/widgets/amount_input.dart';

import '../core/constants.dart';

final TransactionViewModel _transactionVm = sl();

class AddTransactionBottomModal extends StatefulWidget {
  @override
  State<AddTransactionBottomModal> createState() =>
      _AddTransactionBottomModalState();
}

class _AddTransactionBottomModalState extends State<AddTransactionBottomModal> {
  TransactionType _transactionType = TransactionType.expence;
  TransactionCategory? _selecteCategory;
  int _selectedAmount = 0;

  @override
  void initState() {
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
    if (_selecteCategory == null) {
      return _TransactionTypeSelector(
        transactionType: _transactionType,
        onTransactionTypeChanged: (tType) => _transactionType = tType,
        onSelected: (cat) => setState(() => _selecteCategory = cat),
      );
    } else if (_selectedAmount == 0) {
      return _TransactionAmountSelector(
        transactionCategory: _selecteCategory!,
        transactionType: _transactionType,
        onBackButtonPressed: () => setState(() => _selecteCategory = null),
        onSubmitted: (amount) => setState(() => _selectedAmount = amount),
      );
    } else {
      return _TransactionSummary(
        onCategorySelect: () => setState(() => _selecteCategory = null),
        onAmountSelect: () => setState(() => _selectedAmount = 0),
        transactionType: _transactionType,
        category: _selecteCategory!,
        amount: _selectedAmount,
      );
    }
  }
}

class _TransactionTypeSelector extends StatefulWidget {
  final Function(TransactionCategory) onSelected;
  final Function(TransactionType) onTransactionTypeChanged;
  final TransactionType transactionType;

  const _TransactionTypeSelector({
    Key? key,
    required this.onSelected,
    required this.onTransactionTypeChanged,
    required this.transactionType,
  }) : super(key: key);

  @override
  State<_TransactionTypeSelector> createState() =>
      _TransactionTypeSelectorState();
}

class _TransactionTypeSelectorState extends State<_TransactionTypeSelector> {
  late TransactionType _transactionType;
  List<TransactionCategory> _transactionCategoryList = const [];

  void _fetchCategoryList() {
    if (_transactionType.isExpence) {
      _transactionCategoryList = _transactionVm.expenceCategoryList;
    } else if (_transactionType.isIncome) {
      _transactionCategoryList = _transactionVm.incomeCategoryList;
    }
  }

  @override
  void initState() {
    _transactionType = widget.transactionType;
    _fetchCategoryList();

    // Do after init build (So context will have scaffold for snackbar errors)
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (_transactionVm.expenceCategoryList.isEmpty ||
          _transactionVm.incomeCategoryList.isEmpty) {
        await _transactionVm.fetchExpenceCategoryList(context);
        if (!mounted) return;
        await _transactionVm.fetchIncomeCategoryList(context);
        _fetchCategoryList();
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        watch(transactionVmProvider);

        return Column(
          children: [
            SizedBox(
              height: 60.0,
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Add Transaction",
                      style: kTextStyleSubHeading,
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: kColorExpence.withOpacity(
                          _transactionType.isExpence ? 0.3 : 0.0,
                        ),
                      ),
                      onPressed: () => setState(() {
                        _transactionType = TransactionType.expence;
                        _fetchCategoryList();
                        widget.onTransactionTypeChanged(_transactionType);
                      }),
                      child: const Text(
                        "Expence",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: kColorIncome.withOpacity(
                          _transactionType.isIncome ? 0.3 : 0.0,
                        ),
                      ),
                      onPressed: () => setState(() {
                        _transactionType = TransactionType.income;
                        _fetchCategoryList();
                        widget.onTransactionTypeChanged(_transactionType);
                      }),
                      child: const Text(
                        "Income",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: _transactionCategoryList.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                    maxCrossAxisExtent: 100,
                  ),
                  itemBuilder: (context, index) {
                    final category = _transactionCategoryList.elementAt(index);

                    final categoryInUse = _transactionVm.monthTransactionList
                        .where(
                          (trans) => trans.transactionType == _transactionType,
                        )
                        .any(
                          (trans) => trans.category == category,
                        );

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black87,
                        onPrimary: Colors.white,
                      ),
                      onPressed: () => widget.onSelected(category),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(fontSize: 12.0),
                            textAlign: TextAlign.center,
                          ),
                          if (categoryInUse)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  radius: 3.0,
                                  backgroundColor: _transactionType.isExpence
                                      ? kColorExpence
                                      : kColorIncome,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TransactionAmountSelector extends StatefulWidget {
  final Function(int) onSubmitted;
  final Function() onBackButtonPressed;
  final TransactionType transactionType;
  final TransactionCategory transactionCategory;

  const _TransactionAmountSelector({
    Key? key,
    required this.onSubmitted,
    required this.onBackButtonPressed,
    required this.transactionType,
    required this.transactionCategory,
  }) : super(key: key);
  @override
  State<_TransactionAmountSelector> createState() =>
      _TransactionAmountSelectorState();
}

class _TransactionAmountSelectorState
    extends State<_TransactionAmountSelector> {
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
                    widget.transactionCategory.name,
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: widget.transactionType.isExpence
                          ? kColorExpence
                          : kColorIncome,
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
              textColor: widget.transactionType.isExpence
                  ? kColorExpence
                  : kColorIncome,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionSummary extends StatefulWidget {
  final Function() onCategorySelect;
  final Function() onAmountSelect;
  final TransactionType transactionType;
  final int amount;
  final TransactionCategory category;

  const _TransactionSummary({
    Key? key,
    required this.transactionType,
    required this.category,
    required this.amount,
    required this.onCategorySelect,
    required this.onAmountSelect,
  }) : super(key: key);

  @override
  State<_TransactionSummary> createState() => _TransactionSummaryState();
}

class _TransactionSummaryState extends State<_TransactionSummary> {
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
          const Text(
            "Add Transaction",
            style: TextStyle(fontSize: 26.0),
          ),
          const SizedBox(height: 12.0),
          Text(
            widget.transactionType.display,
            style: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
              color: widget.transactionType.isExpence
                  ? kColorExpence
                  : kColorIncome,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                "Category",
                style: _kLableStyle,
                textAlign: TextAlign.end,
              ),
              const SizedBox(width: _kLableWidth),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () => widget.onCategorySelect(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.category.name,
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
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                "Date",
                style: _kLableStyle,
                textAlign: TextAlign.end,
              ),
              const SizedBox(width: _kLableWidth),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () => null,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Today",
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
              watch(transactionVmProvider);
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                  onPrimary: Colors.black87,
                ),
                onPressed: () async {
                  final success = await _transactionVm.addTransaction(
                    context,
                    Transaction(
                      uuid: "",
                      amount: widget.amount,
                      timestamp: DateTime.now(),
                      transactionType: widget.transactionType,
                      category: widget.category,
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
