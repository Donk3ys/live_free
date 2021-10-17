import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_free/data_models/user.dart';
import 'package:live_free/main.dart';
import 'package:live_free/view_models/finance_vm.dart';
import 'package:live_free/view_models/network_vm.dart';
import 'package:live_free/view_models/theme_vm.dart';
import 'package:live_free/widgets/bottom_nav.dart';
import 'package:live_free/widgets/loading.dart';

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
      _financeVm.doSomething(context);
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
                _FinanceTypeListView(),
              ],
            ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 0),
          ),
        );
      },
    );
  }
}

class _FinanceTypeListView extends ConsumerWidget {
  const _FinanceTypeListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final financeVm = watch(financeVmProvider);

    if (financeVm.isBusy) {
      return const SliverCircularLoading();
    }

    final incomeItemList = [
      IncomeItem(uuid: "1", name: "Salary", amount: 20000)
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final item = incomeItemList.elementAt(index);
          return ListTile(
            title: Text(item.name),
            trailing: Text("R ${(item.amount / 100).toStringAsFixed(2)}"),
          );
        },
        childCount: incomeItemList.length,
      ),
    );
  }
}
