import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_free/core/constants.dart';
import 'package:live_free/core/util_core.dart';
import 'package:live_free/service_locator.dart';
import 'package:live_free/widgets/dialog.dart';
import 'package:live_free/widgets/loading.dart';

class AllTransactionHistoryPage extends StatefulWidget {
  const AllTransactionHistoryPage({Key? key}) : super(key: key);

  @override
  _AllTransactionHistoryPageState createState() =>
      _AllTransactionHistoryPageState();
}

class _AllTransactionHistoryPageState extends State<AllTransactionHistoryPage>
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
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      transactionVm.fetchAllTransactions(context);
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
          child: Consumer(
            builder: (context, watch, child) {
              watch(transactionVmProvider);
              final transactionList = transactionVm.allTransactionList;

              return Scaffold(
                body: Padding(
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
                        Expanded(
                          child: ListView.builder(
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
                                                  transaction.amount),
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
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Transaction History",
                          style: kTextStyleSubHeading,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
