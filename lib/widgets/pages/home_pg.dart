import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_free/core/constants.dart';
import 'package:live_free/data_models/transaction.dart';
import 'package:live_free/main.dart';
import 'package:live_free/view_models/finance_vm.dart';
import 'package:live_free/view_models/network_vm.dart';
import 'package:live_free/view_models/theme_vm.dart';
import 'package:live_free/widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final TransactionViewModel _transactionVm;
  late final NetworkViewModel _networkVm;
  late final ThemeViewModel _themeVm;

  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _transactionVm = context.read(transactionVmProvider);
    _networkVm = context.read(networkVMProvider);
    _themeVm = context.read(themeVMProvider);

    // Do after init build (So context will have scaffold for snackbar errors)
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _transactionVm.fetchExpenceCategoryList(context);
      _transactionVm.fetchExpenceCategoryList(context);
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
            bottomNavigationBar: const BottomNavBar(currentIndex: 0),
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
        onSelected: (cat) => setState(() => _selecteCategory = cat),
      );
    } else if (_selectedAmount == 0.0) {
      return _TransactionAmountSelector(
        transactionType: _transactionType,
        onSubmitted: (amount) => setState(() => _selectedAmount = amount),
      );
    } else {
      return _TransactionSummary(
        transactionType: _transactionType,
        category: _selecteCategory!,
        amount: _selectedAmount,
      );
    }
  }
}

class _TransactionTypeSelector extends ConsumerWidget {
  final Function(TransactionCategory) onSelected;
  final TransactionType transactionType;

  const _TransactionTypeSelector({
    Key? key,
    required this.onSelected,
    required this.transactionType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final transactionVm = watch(transactionVmProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: transactionVm.expenceCategoryList.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          maxCrossAxisExtent: 100,
        ),
        itemBuilder: (context, index) {
          final category = transactionVm.expenceCategoryList.elementAt(index);
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.black87,
              onPrimary: Colors.white,
            ),
            onPressed: () => onSelected(category),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(fontSize: 12.0),
                  textAlign: TextAlign.center,
                ),
                if (transactionVm.monthTransactionList.any(
                  (trans) => trans.isExpence && trans.category == category,
                ))
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 3.0,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TransactionAmountSelector extends StatefulWidget {
  final Function(double) onSubmitted;
  final TransactionType transactionType;

  const _TransactionAmountSelector({
    Key? key,
    required this.onSubmitted,
    required this.transactionType,
  }) : super(key: key);
  @override
  State<_TransactionAmountSelector> createState() =>
      _TransactionAmountSelectorState();
}

class _TransactionAmountSelectorState
    extends State<_TransactionAmountSelector> {
  double _amount = 0.0;
  final _amountStyle = const TextStyle(fontSize: 30.0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Row(
          children: [
            Text("R", style: _amountStyle),
            const SizedBox(width: 20.0),
            Expanded(
              child: TextField(
                onChanged: (amount) => setState(() {
                  _amount = double.tryParse(amount) ?? 0.0;
                  if (widget.transactionType.isIncome && _amount <= -0.01) {
                    _amount = _amount * -1;
                  }
                  if (widget.transactionType.isExpence && _amount >= 0.01) {
                    _amount = _amount * -1;
                  }
                }),
                onSubmitted: (_) {
                  if (_amount == 0.0) {
                  } else {
                    widget.onSubmitted(_amount);
                  }
                },
                decoration: const InputDecoration(hintText: "0.00"),
                style: _amountStyle,
                textAlign: TextAlign.end,
                inputFormatters: [CurrencyTextInputFormatter(symbol: "")],
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionSummary extends StatefulWidget {
  final TransactionType transactionType;
  final double amount;
  final TransactionCategory category;

  const _TransactionSummary({
    Key? key,
    required this.transactionType,
    required this.category,
    required this.amount,
  }) : super(key: key);

  @override
  State<_TransactionSummary> createState() => _TransactionSummaryState();
}

class _TransactionSummaryState extends State<_TransactionSummary> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text("Category: ${widget.category.name}"),
          Text("Amount: ${widget.amount}"),
          const Text("Date: Today"),
          Consumer(
            builder: (context, watch, child) {
              final transactionVm = watch(transactionVmProvider);
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black87,
                  onPrimary: Colors.white,
                ),
                onPressed: () => transactionVm.addTransaction(
                  context,
                  Transaction(
                    uuid: (transactionVm.monthTransactionList.length + 1)
                        .toString(),
                    amount: (widget.amount * 100).round(),
                    timestamp: DateTime.now(),
                    transactionType: widget.transactionType,
                    category: widget.category,
                  ),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 12.0),
                  textAlign: TextAlign.center,
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
