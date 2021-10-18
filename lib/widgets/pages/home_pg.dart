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
  late final FinanceViewModel _financeVm;
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
    _financeVm = context.read(financeVmProvider);
    _networkVm = context.read(networkVMProvider);
    _themeVm = context.read(themeVMProvider);

    // Do after init build (So context will have scaffold for snackbar errors)
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _financeVm.fetchMonthTransactions(context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (ctx, watch, child) {
        watch(financeVmProvider);
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
              onPressed: () => null,
              child: const Icon(Icons.add),
            ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 0),
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
    final financeVm = watch(financeVmProvider);

    final transactionList = financeVm.monthTransactionList;
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
                              Text(transaction.type.toString()),
                              Text(
                                "R ${(transaction.amount / 100).toStringAsFixed(2)}",
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
