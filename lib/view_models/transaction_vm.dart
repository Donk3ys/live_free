import 'package:flutter/material.dart';
import 'package:live_free/data_models/transaction.dart';
import 'package:live_free/repositories/finance_repo.dart';
import 'package:live_free/view_models/utils_vm.dart';
import 'package:uuid/uuid.dart';

enum _State {
  idle,
  error,
  fetchingTransactions,
  addingTransaction,
  removingTransaction
}

class TransactionViewModel extends ChangeNotifier {
  final FinanceRepository _financeRepository;
  TransactionViewModel({
    required FinanceRepository financeRepository,
  }) : _financeRepository = financeRepository;

  _State _state = _State.fetchingTransactions;
  void _setState(_State viewState) {
    _state = viewState;
    notifyListeners();
  }

  List<TransactionCategory> expenceCategoryList = const [];
  List<TransactionCategory> incomeCategoryList = const [];
  List<Transaction> currentMonthTransactionList = const [];
  List<Transaction> lastMonthTransactionList = const [];
  List<Transaction> allTransactionList = const [];

  bool get isFetchingTransactions => _state == _State.fetchingTransactions;
  bool get isAddingTransaction => _state == _State.addingTransaction;
  bool get isRemovingTransaction => _state == _State.removingTransaction;
  bool get hasError => _state == _State.error;

  // TODO: change to projected expence
  int totalMonthAmount(TransactionType type) {
    int total = 0;
    for (final trans in currentMonthTransactionList) {
      if (type == TransactionType.expence ? trans.isExpence : trans.isIncome) {
        total += trans.amount;
      }
    }
    return total;
  }

  int get totalMonthExpence => totalMonthAmount(TransactionType.expence);

  int get totalMonthIncome => totalMonthAmount(TransactionType.income);

  int get totalNet {
    int total = 0;
    for (final item in currentMonthTransactionList) {
      total = total + item.amount;
    }
    return total;
  }

  int get target6MEF => totalMonthExpence * -6;
  int get targetLiveFree => totalMonthExpence * -12 * 25;

  int current6MEF(int totalSavings) {
    int current6MEF = totalSavings;
    if (totalSavings > target6MEF) current6MEF = target6MEF;
    return current6MEF;
  }

  int currentLiveFree(int totalSavings) {
    int currentLF = 0;
    if (totalSavings > target6MEF) {
      currentLF = totalSavings - current6MEF(totalSavings);
    }
    return currentLF;
  }

  int _get6MonthsNet(int totalSavings) {
    final diff = target6MEF - current6MEF(totalSavings);
    if (diff <= 0) return 0;
    return (diff / totalNet).ceil();
  }

  // TODO: calc properly
  String timeToTarget6MEF(int totalSavings) {
    final months = _get6MonthsNet(totalSavings);
    if (months == 0) return "Complete";
    String timeLeft = "$months months";
    if (months >= 12) timeLeft = "${(months / 12).toStringAsFixed(1)} years";
    return timeLeft;
  }

  // TODO: calc properly
  String timeToTargetLF(int totalSavings) {
    final diff = targetLiveFree - currentLiveFree(totalSavings);
    if (diff <= 0) return "Complete";
    final months = (diff / totalNet).ceil() + 1 + _get6MonthsNet(totalSavings);
    String timeLeft = "$months months";
    if (months >= 12) timeLeft = "${(months / 12).toStringAsFixed(1)} years";
    return timeLeft;
  }

  Future<void> fetchExpenceCategoryList(
    BuildContext context,
  ) async =>
      _makeCall(context, () async {
        final list = await _financeRepository.doSomething();
        incomeCategoryList = [
          TransactionCategory(id: 0, name: "Other"),
          TransactionCategory(id: 1, name: "Salary"),
          TransactionCategory(id: 2, name: "Sale"),
          TransactionCategory(id: 3, name: "Gift"),
          TransactionCategory(id: 4, name: "Rent"),
          TransactionCategory(id: 5, name: "Bonus"),
          TransactionCategory(id: 6, name: "Gambling"),
        ];
        // Sort list
        incomeCategoryList.sort((a, b) => a.name.compareTo(b.name));
      });

  Future<void> fetchIncomeCategoryList(
    BuildContext context,
  ) async =>
      _makeCall(context, () async {
        final list = await _financeRepository.doSomething();
        expenceCategoryList = [
          TransactionCategory(id: 1, name: "Loan Payment"),
          TransactionCategory(id: 2, name: "Food"),
          TransactionCategory(id: 3, name: "Rent"),
          TransactionCategory(id: 4, name: "Medical"),
          TransactionCategory(id: 5, name: "Personal Care"),
          TransactionCategory(id: 6, name: "Gas"),
          TransactionCategory(id: 9, name: "Travel"),
          TransactionCategory(id: 10, name: "Gifts"),
          TransactionCategory(id: 11, name: "Entertain"),
          TransactionCategory(id: 12, name: "Education"),
          TransactionCategory(id: 13, name: "Other"),
          TransactionCategory(id: 14, name: "Gambling"),
          TransactionCategory(id: 15, name: "Asset Maintain"),
        ];

        // Sort list
        expenceCategoryList.sort((a, b) => a.name.compareTo(b.name));
      });

  Future<void> fetchMonthTransactions(
    BuildContext context,
  ) async =>
      _makeCall(context, () async {
        _setState(_State.fetchingTransactions);

        final list = await _financeRepository.fetchTransactionHistory();
        final thisMonth = DateTime(DateTime.now().year, DateTime.now().month);
        currentMonthTransactionList = list
            .where(
              (transaction) =>
                  DateTime(
                    transaction.timestamp.year,
                    transaction.timestamp.month,
                  ) ==
                  thisMonth,
            )
            .toList();
        final lastMonth = DateTime(thisMonth.year, thisMonth.month - 1);
        lastMonthTransactionList = list
            .where(
              (transaction) =>
                  DateTime(
                    transaction.timestamp.year,
                    transaction.timestamp.month,
                  ) ==
                  lastMonth,
            )
            .toList();

        // Sort by date
        currentMonthTransactionList
            .sort((a, b) => b.timestamp.compareTo(a.timestamp));
        lastMonthTransactionList
            .sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });

  Future<void> fetchAllTransactions(
    BuildContext context,
  ) async =>
      _makeCall(context, () async {
        _setState(_State.fetchingTransactions);

        allTransactionList = await _financeRepository.fetchTransactionHistory();
        // Sort by date
        allTransactionList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });

  Future<bool> addTransaction(
    BuildContext context,
    Transaction transaction,
  ) async {
    try {
      _setState(_State.addingTransaction);

      final newTransaction = transaction.copyWith(uuid: const Uuid().v1());

      await _financeRepository.addTransaction(newTransaction);
      currentMonthTransactionList.add(newTransaction);
      // Sort by date
      currentMonthTransactionList
          .sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // await Future.delayed(const Duration(milliseconds: 1000));
      _setState(_State.idle);
      return true;
    } catch (e, s) {
      ViewModelUtil.handleException(
        e,
        s,
        context: context,
      );
      _setState(_State.idle);
      return false;
    }
  }

  Future<void> removeTransaction(
    BuildContext context,
    Transaction transaction,
  ) async =>
      _makeCall(context, () async {
        _setState(_State.removingTransaction);

        await _financeRepository.removeTransaction(transaction);
        currentMonthTransactionList.remove(transaction);
        // lastMonthTransactionList.remove(transaction);
        allTransactionList.remove(transaction);
      });

  // NOTE: wrapper for return void
  Future<void> _makeCall(BuildContext context, Function call) async {
    try {
      await call();
    } catch (e, s) {
      ViewModelUtil.handleException(
        e,
        s,
        context: context,
      );
    }
    //await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
  }
}
