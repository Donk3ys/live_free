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
  List<Transaction> monthTransactionList = const [];

  bool get isFetchingTransactions => _state == _State.fetchingTransactions;
  bool get isAddingTransaction => _state == _State.addingTransaction;
  bool get isRemovingTransaction => _state == _State.removingTransaction;
  bool get hasError => _state == _State.error;

  // TODO: change to projected expence
  int get totalMonthExpence {
    int totalExpence = 0;
    for (final trans in monthTransactionList) {
      if (trans.isExpence) totalExpence += trans.amount;
    }
    return totalExpence;
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

  // TODO: calc properly
  String timeToTarget6MEF(int totalSavings) {
    final diff = target6MEF - current6MEF(totalSavings);
    if (diff <= 0) return "DONE!!!!";
    final months = (diff / totalMonthExpence).ceil();
    String timeLeft = "$months months";
    if (months >= 12) timeLeft = "${(months / 12).toStringAsFixed(1)} years";
    return timeLeft;
  }

  // TODO: calc properly
  String timeToTargetLF(int totalSavings) {
    final diff = targetLiveFree - currentLiveFree(totalSavings);
    if (diff <= 0) return "DONE!!!!";
    final months = (diff / -totalMonthExpence).ceil() + 1;
    String timeLeft = "$months months";
    if (months >= 12) timeLeft = "${(months / 12).toStringAsFixed(1)} years";
    return timeLeft;
  }

  Future<void> fetchExpenceCategoryList(BuildContext context) async {
    final failureOrList = await _financeRepository.doSomething();
    failureOrList.fold(
      (failure) {
        ViewModelUtil.handleFailure(
          context: context,
          failure: failure,
          showErrorSnackbar: false,
        );
      },
      (list) {
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
        ];

        // Sort list
        expenceCategoryList.sort((a, b) => a.name.compareTo(b.name));
      },
    );
    await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
  }

  Future<void> fetchIncomeCategoryList(BuildContext context) async {
    final failureOrList = await _financeRepository.doSomething();
    failureOrList.fold(
      (failure) {
        ViewModelUtil.handleFailure(
          context: context,
          failure: failure,
          showErrorSnackbar: false,
        );
      },
      (list) {
        incomeCategoryList = [
          TransactionCategory(id: 0, name: "Other"),
          TransactionCategory(id: 1, name: "Salary"),
          TransactionCategory(id: 2, name: "Sale"),
          TransactionCategory(id: 3, name: "Gift"),
          TransactionCategory(id: 4, name: "Rent"),
          TransactionCategory(id: 5, name: "Bonus"),
        ];
        // Sort list
        incomeCategoryList.sort((a, b) => a.name.compareTo(b.name));
      },
    );
    await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
  }

  Future<void> fetchMonthTransactions(BuildContext context) async {
    _setState(_State.fetchingTransactions);

    final failOrList = await _financeRepository.fetchTransactionHistory();
    failOrList.fold(
      (failure) {
        ViewModelUtil.handleFailure(
          context: context,
          failure: failure,
        );
      },
      (list) {
        monthTransactionList = list;

        // Sort by date
        monthTransactionList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      },
    );

    await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
  }

  Future<bool> addTransaction(
    BuildContext context,
    Transaction transaction,
  ) async {
    _setState(_State.addingTransaction);
    bool success = false;

    final newTransaction = transaction.copyWith(uuid: const Uuid().v1());

    final failOrSuccess =
        await _financeRepository.addTransaction(newTransaction);
    failOrSuccess.fold(
      (failure) {
        ViewModelUtil.handleFailure(
          context: context,
          failure: failure,
        );
      },
      (_) {
        monthTransactionList.add(newTransaction);
        // Sort by date
        monthTransactionList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        success = true;
      },
    );

    // await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
    return success;
  }

  Future<void> removeTransaction(
    BuildContext context,
    Transaction transaction,
  ) async {
    _setState(_State.removingTransaction);

    final failOrSuccess =
        await _financeRepository.removeTransaction(transaction);
    failOrSuccess.fold(
      (failure) {
        ViewModelUtil.handleFailure(
          context: context,
          failure: failure,
        );
      },
      (_) {
        monthTransactionList.remove(transaction);
      },
    );

    // await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
  }
}
