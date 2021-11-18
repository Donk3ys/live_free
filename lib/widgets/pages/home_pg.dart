import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_free/core/constants.dart';
import 'package:live_free/core/util_core.dart';
import 'package:live_free/service_locator.dart';
import 'package:live_free/widgets/add_saving_bottom_modal.dart';
import 'package:live_free/widgets/add_transaction_bottom_modal.dart';
import 'package:live_free/widgets/dialog.dart';
import 'package:live_free/widgets/loading.dart';
import 'package:vrouter/vrouter.dart';

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

        // final themeVM = watch(themeVMProvider);
        return SafeArea(
          child: Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: const [
                _SavingsListView(),
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
                    onPressed: () =>
                        context.vRouter.to(kMonthTransactionsRoute),
                    child: const Text(
                      "Month",
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.vRouter.to(kAllTransactionsRoute),
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
                        key: UniqueKey(),
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
                    formatNumAmount(transactionVm.totalNet),
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
    watch(transactionVmProvider);
    watch(savingVmProvider);
    final savingList = savingVm.savingList;
    final _totalSavings = savingVm.totalSavings;

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
                        key: UniqueKey(),
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
                const SizedBox(height: 20.0),
                _LiveFreeTile(
                  name: "6 Month Emergency Fund",
                  targetAmount: transactionVm.target6MEF,
                  currentAmount: transactionVm.current6MEF(_totalSavings),
                  timeToTarget: transactionVm.timeToTarget6MEF(_totalSavings),
                ),
                _LiveFreeTile(
                  name: "Live Free Savings",
                  targetAmount: transactionVm.targetLiveFree,
                  currentAmount: transactionVm.currentLiveFree(_totalSavings),
                  timeToTarget: transactionVm.timeToTargetLF(_totalSavings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveFreeTile extends StatelessWidget {
  final String name;
  final int targetAmount;
  final int currentAmount;
  final String timeToTarget;
  const _LiveFreeTile({
    Key? key,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.timeToTarget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatNumAmount(currentAmount),
                  style: const TextStyle(
                    color: kColorAccent,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Target   ",
                  style: kTextStyleSmallSecondary,
                ),
                Text(
                  formatNumAmount(targetAmount),
                  style: const TextStyle(
                    color: kColorAccent,
                  ),
                ),
                const Expanded(child: SizedBox()),
                const Text(
                  "Time to target   ",
                  style: kTextStyleSmallSecondary,
                ),
                Text(
                  timeToTarget,
                  style: const TextStyle(color: kColorAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
