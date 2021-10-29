import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_free/core/constants.dart';
import 'package:live_free/core/util_core.dart';
import 'package:live_free/data_models/transaction.dart';
import 'package:live_free/service_locator.dart';
import 'package:live_free/widgets/dialog.dart';

class TransactionTypePage extends StatefulWidget {
  const TransactionTypePage({Key? key}) : super(key: key);

  @override
  _TransactionTypePageState createState() => _TransactionTypePageState();
}

class _TransactionTypePageState extends State<TransactionTypePage>
    with WidgetsBindingObserver {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // Do after init build (So context will have scaffold for snackbar errors)
    WidgetsBinding.instance!.addPostFrameCallback((_) async {});

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
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    width: double.infinity,
                    child: const Text(
                      "Income",
                      style: kTextStyleHeading,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                const _MonthTransactionCategoryListView(
                  transactionType: TransactionType.income,
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    width: double.infinity,
                    child: const Text(
                      "Expence",
                      style: kTextStyleHeading,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                const _MonthTransactionCategoryListView(
                  transactionType: TransactionType.expence,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MonthTransactionCategoryListView extends StatefulWidget {
  final TransactionType transactionType;

  const _MonthTransactionCategoryListView({
    Key? key,
    required this.transactionType,
  }) : super(key: key);

  @override
  State<_MonthTransactionCategoryListView> createState() =>
      _MonthTransactionCategoryListViewState();
}

class _MonthTransactionCategoryListViewState
    extends State<_MonthTransactionCategoryListView> {
  List<List<Transaction>> _transactionCategoryList = [];

  int _getTotal(List<Transaction> items) {
    int total = 0;
    for (final item in items) {
      total = total + item.amount;
    }
    return total;
  }

  List<List<Transaction>> _createListByCategoryType() {
    final transactionCategoryList = <List<Transaction>>[];
    final typeFilteredList = transactionVm.monthTransactionList
        .where((tran) => tran.transactionType == widget.transactionType);
    if (typeFilteredList.isEmpty) return transactionCategoryList;

    transactionCategoryList.add([typeFilteredList.first]);
    for (final trans in typeFilteredList) {
      bool added = false;
      for (final categoryList in transactionCategoryList) {
        if (trans.category == categoryList.first.category) {
          categoryList.add(trans);
          added = true;
        }
      }
      if (!added) transactionCategoryList.add([trans]);
    }
    transactionCategoryList.first.removeAt(0);

    return transactionCategoryList;
  }

  @override
  void initState() {
    _transactionCategoryList = _createListByCategoryType();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        watch(transactionVmProvider);

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final transactionList = _transactionCategoryList.elementAt(index);
              final category = transactionList.first.category;
              final total = _getTotal(transactionList);

              bool showList = false;

              return StatefulBuilder(
                builder: (context, setListState) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 20.0,
                          child: ListTile(
                            onTap: () =>
                                setListState(() => showList = !showList),
                            title: Text(
                              category.name.toUpperCase(),
                              style: TextStyle(
                                color: widget.transactionType.isIncome
                                    ? kColorIncome
                                    : kColorExpence,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              formatNumAmount(total),
                              // style: _expenceHeaderStyle,
                            ),
                            trailing: Icon(
                              showList
                                  ? Icons.arrow_drop_down
                                  : Icons.arrow_right,
                            ),
                          ),
                        ),
                        if (showList)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 4.0, right: 20.0),
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: transactionList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final transaction =
                                    transactionList.elementAt(index);

                                return Card(
                                  child: InkWell(
                                    onLongPress: () async {
                                      final confirmDel = await showDialog(
                                        context: context,
                                        builder: (ctx) => ConfirmDeleteDialog(
                                          bodyText:
                                              "${transaction.category.name} : ${formatNumAmount(transaction.amount)}",
                                        ),
                                      ) as bool?;

                                      if (!mounted) return;
                                      if (confirmDel != null && confirmDel) {
                                        transactionVm.removeTransaction(
                                          context,
                                          transaction,
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(transaction.category.name),
                                              Text(
                                                formatNumAmount(
                                                  transaction.amount,
                                                ),
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
                          ),
                        const SizedBox(height: 18.0),
                      ],
                    ),
                  );
                },
              );
            },
            childCount: _transactionCategoryList.length,
          ),
        );
      },
    );
  }
}
