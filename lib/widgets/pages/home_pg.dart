import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_free/core/constants.dart';
import 'package:live_free/data_models/transaction.dart';
import 'package:live_free/service_locator.dart';
import 'package:live_free/view_models/transaction_vm.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';

late TransactionViewModel _transactionVm;
//   late final NetworkViewModel _networkVm;
//   late final ThemeViewModel _themeVm;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _transactionVm = context.read(transactionVmProvider);
//     _networkVm = context.read(networkVMProvider);
//     _themeVm = context.read(themeVMProvider);

    // Do after init build (So context will have scaffold for snackbar errors)
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (_transactionVm.expenceCategoryList.isEmpty) {
        _transactionVm.fetchExpenceCategoryList(context);
      }
      if (_transactionVm.incomeCategoryList.isEmpty) {
        _transactionVm.fetchIncomeCategoryList(context);
      }
      _transactionVm.fetchMonthTransactions(context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        watch(transactionVmProvider);
        watch(themeVMProvider);
        watch(networkVMProvider);

        // final themeVM = watch(themeVMProvider);
        return SafeArea(
          child: Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: const [
                _MonthTransactionListView(),
              ],
            ),
//             bottomSheet: BottomSheet(
//               onClosing: () => null,
//               builder: (context) {
//                 return Container(
//                   color: Colors.redAccent,
//                 );
//               },
//             ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) => _AddTransactionBottomModal(),
              ),
              child: const Icon(Icons.add),
            ),
            // bottomNavigationBar: const BottomNavBar(currentIndex: 0),
          ),
        );
      },
    );
  }
}

class _AddTransactionBottomModal extends StatefulWidget {
  @override
  State<_AddTransactionBottomModal> createState() =>
      _AddTransactionBottomModalState();
}

class _AddTransactionBottomModalState
    extends State<_AddTransactionBottomModal> {
  TransactionType _transactionType = TransactionType.expence;
  TransactionCategory? _selecteCategory;
  double _selectedAmount = 0.0;

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
    } else if (_selectedAmount == 0.0) {
      return _TransactionAmountSelector(
        transactionCategory: _selecteCategory!,
        transactionType: _transactionType,
        onBackButtonPressed: () => setState(() => _selecteCategory = null),
        onSubmitted: (amount) => setState(() => _selectedAmount = amount),
      );
    } else {
      return _TransactionSummary(
        onCategorySelect: () => setState(() => _selecteCategory = null),
        onAmountSelect: () => setState(() => _selectedAmount = 0.0),
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
    _transactionVm = context.read(transactionVmProvider);
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
  final Function(double) onSubmitted;
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
  String _amount = "";
  final _amountStyle = const TextStyle(fontSize: 30.0);

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
            Text(_amount.isNotEmpty ? _amount : "R 0.00", style: _amountStyle),
            NumericKeyboard(
              onKeyboardTap: (number) => setState(() {
                _amount = _amount + number;
                _amount =
                    CurrencyTextInputFormatter(symbol: "R ").format(_amount);
              }),
              textColor: widget.transactionType.isExpence
                  ? kColorExpence
                  : kColorIncome,
              rightButtonFn: () {
                setState(() {
                  _amount = _amount.substring(0, _amount.length - 1);
                  _amount =
                      CurrencyTextInputFormatter(symbol: "R ").format(_amount);
                });
              },
              leftButtonFn: () {
                setState(() {
                  final amount = double.tryParse(
                        _amount.substring(1, _amount.length - 1),
                      ) ??
                      0;
                  if (amount == 0.0) {
                  } else {
                    widget.onSubmitted(amount);
                  }
                });
              },
              rightIcon: Icon(
                Icons.backspace,
                color: widget.transactionType.isExpence
                    ? kColorExpence
                    : kColorIncome,
              ),
              leftIcon: Icon(
                Icons.check,
                color: widget.transactionType.isExpence
                    ? kColorExpence
                    : kColorIncome,
              ),
            ),

//             Card(
//               child: TextField(
//                 onChanged: (amount) => setState(() {
//                   _amount = double.tryParse(amount) ?? 0.0;
//                   if (widget.transactionType.isIncome && _amount <= -0.01) {
//                     _amount = _amount * -1;
//                   }
//                   if (widget.transactionType.isExpence && _amount >= 0.01) {
//                     _amount = _amount * -1;
//                   }
//                 }),
//                 onSubmitted: (_) {
//                   if (_amount == 0.0) {
//                   } else {
//                     widget.onSubmitted(_amount);
//                   }
//                 },
//                 decoration: const InputDecoration(
//                   hintText: "R 0.00",
//                   border: InputBorder.none,
//                   focusedBorder: InputBorder.none,
//
//                 ),
//                 controller: _tx,
//                 style: _amountStyle,
//                 textAlign: TextAlign.center,
//                 inputFormatters: [CurrencyTextInputFormatter(symbol: "R ")],
//                 keyboardType: TextInputType.number,
//                 autofocus: true,
//               ),
//             ),
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
  final double amount;
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
  static const _kLableWidth = 40.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text(
            "Transaction Summary",
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  "Category",
                  style: _kLableStyle,
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: _kLableWidth),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onCategorySelect(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.category.name,
                      style: _kTransactionItemStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  "Amount",
                  style: _kLableStyle,
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: _kLableWidth),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onAmountSelect(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "R ${widget.amount}",
                      style: _kTransactionItemStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  "Date",
                  style: _kLableStyle,
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: _kLableWidth),
              Expanded(
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
              final transactionVm = watch(transactionVmProvider);
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                  onPrimary: Colors.black87,
                ),
                onPressed: () async {
                  final success = await transactionVm.addTransaction(
                    context,
                    Transaction(
                      uuid: (transactionVm.monthTransactionList.length + 1)
                          .toString(),
                      amount: (widget.amount * 100).round(),
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

class _MonthTransactionListView extends ConsumerWidget {
  const _MonthTransactionListView({Key? key}) : super(key: key);

  int _getTotal(List<Transaction> items) {
    int total = 0;
    for (final item in items) {
      total = total + item.amount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final transactionVm = watch(transactionVmProvider);

    final transactionList = transactionVm.monthTransactionList;
    final total = _getTotal(transactionList);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            child: const Text(
              "This Month",
              style: kTextStyleHeading,
              textAlign: TextAlign.start,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Type", style: kTextStyleSmallSecondary),
                    Text("Amount", style: kTextStyleSmallSecondary),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: transactionList.length,
                itemBuilder: (BuildContext context, int index) {
                  final transaction = transactionList.elementAt(index);
                  return Card(
                    child: InkWell(
                      onLongPress: () =>
                          transactionVm.removeTransaction(context, transaction),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(transaction.category.name),
                                Text(
                                  (transaction.amount / 100).toStringAsFixed(2),
                                  style: TextStyle(
                                    color: transaction.isIncome
                                        ? kColorIncome
                                        : kColorExpence,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              DateFormat("EEE d/M/y")
                                  .format(transaction.timestamp),
                              style: kTextStyleSmallSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "R ${(total / 100).toStringAsFixed(2)}",
                  style: kTextStyleSubHeading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
