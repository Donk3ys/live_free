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
import 'package:live_free/widgets/add_saving_bottom_modal.dart';
import 'package:live_free/widgets/add_transaction_bottom_modal.dart';
import 'package:live_free/widgets/dialog.dart';
import 'package:live_free/widgets/loading.dart';
import 'package:live_free/widgets/pages/transaction_type_pg.dart';

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
    // Do after init build (So context will have scaffold for snackbar errors)
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (transactionVm.expenceCategoryList.isEmpty) {
        transactionVm.fetchExpenceCategoryList(context);
      }
      if (transactionVm.incomeCategoryList.isEmpty) {
        transactionVm.fetchIncomeCategoryList(context);
      }
      transactionVm.fetchMonthTransactions(context);
      savingVm.fetchSavingList(context);
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

        final _totalSavings = savingVm.totalSavings;
        // final themeVM = watch(themeVMProvider);
        return SafeArea(
          child: Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const _SavingsListView(),
                const _MonthTransactionListView(),
                SliverToBoxAdapter(
                  child: Text(
                    "Target E6EF: ${formatNumAmount(transactionVm.target6MEF)}",
                  ),
                ),
                SliverToBoxAdapter(
                  child: Text(
                    "Current E6EF: ${formatNumAmount(transactionVm.current6MEF(_totalSavings))}",
                  ),
                ),
                SliverToBoxAdapter(
                  child: Text(
                    "Time to E6EF: ${transactionVm.timeToTarget6MEF(_totalSavings)}",
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20.0)),
                SliverToBoxAdapter(
                  child: Text(
                    "Target Live Free: ${formatNumAmount(transactionVm.targetLiveFree)}",
                  ),
                ),
                SliverToBoxAdapter(
                  child: Text(
                    "Current Live Free: ${formatNumAmount(transactionVm.currentLiveFree(_totalSavings))}",
                  ),
                ),
                SliverToBoxAdapter(
                  child: Text(
                    "Time to E6EF: ${transactionVm.timeToTargetLF(_totalSavings)}",
                  ),
                ),
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
                builder: (BuildContext context) => AddTransactionBottomModal(),
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
    watch(transactionVmProvider);
    final transactionList = transactionVm.currentMonthTransactionList;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 20.0),
          Card(
            elevation: 20.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "This Month",
                      style: kTextStyleHeading,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const TransactionHistoryPage(),
                      ),
                    ),
                    child: const Text(
                      "All",
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Column(
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
                if (transactionVm.isFetchingTransactions)
                  const LoadingWidget()
                else
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    // itemCount: transactionList.length,
                    itemCount:
                        transactionList.length > 3 ? 3 : transactionList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final transaction = transactionList.elementAt(index);

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

                            // if (!mounted) return;
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(transaction.category.name),
                                    Text(
                                      formatNumAmount(transaction.amount),
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
                    formatNumAmount(_getTotal(transactionList)),
                    style: kTextStyleSubHeading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsListView extends ConsumerWidget {
  const _SavingsListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    watch(savingVmProvider);
    final savingList = savingVm.savingList;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Card(
            elevation: 20.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Current Savings",
                    style: kTextStyleHeading,
                    textAlign: TextAlign.start,
                  ),
                  IconButton(
                    onPressed: () async => showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) => AddSavingBottomModal(),
                    ),
                    icon: const Icon(
                      Icons.add,
                      color: kColorSaving,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Name", style: kTextStyleSmallSecondary),
                      Text("Amount", style: kTextStyleSmallSecondary),
                    ],
                  ),
                ),
                if (savingVm.isFetchingSaving)
                  const LoadingWidget()
                else
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: savingList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final saving = savingList.elementAt(index);
                      return Card(
                        child: InkWell(
                          onLongPress: () async {
                            final confirmDel = await showDialog(
                              context: context,
                              builder: (ctx) => ConfirmDeleteDialog(
                                bodyText:
                                    "${saving.name} : ${formatNumAmount(saving.amount)}",
                              ),
                            ) as bool?;

                            // if (!mounted) return;
                            if (confirmDel != null && confirmDel) {
                              savingVm.removeSaving(context, saving);
                            }
                          },
                          // transactionVm.removeTransaction(context, transaction),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(saving.name),
                                    Text(
                                      formatNumAmount(saving.amount),
                                      style: const TextStyle(
                                        color: kColorSaving,
                                      ),
                                    ),
                                  ],
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
                    formatNumAmount(savingVm.totalSavings),
                    style: kTextStyleSubHeading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
