import 'package:flutter/material.dart';
import 'package:live_free/data_models/transaction.dart';
import 'package:live_free/repositories/finance_repo.dart';
import 'package:live_free/view_models/utils_vm.dart';

enum _State { idle, error, fetchingTransactions, addingTransaction }

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
  bool get hasError => _state == _State.error;

  Future<void> fetchExpenceCategoryList(BuildContext context) async {
    final failureOrUser = await _financeRepository.doSomething();
    failureOrUser.fold(
      (failure) {
        ViewModelUtil.handleFailure(
          context: context,
          failure: failure,
          showErrorSnackbar: false,
        );
      },
      (_) {
        expenceCategoryList = [
          TransactionCategory(id: 0, name: "Gas"),
          TransactionCategory(id: 1, name: "Food"),
          TransactionCategory(id: 2, name: "Eat Out"),
          TransactionCategory(id: 3, name: "Rent"),
          TransactionCategory(id: 4, name: "Medical"),
          TransactionCategory(id: 5, name: "Persoanl Care"),
          TransactionCategory(id: 6, name: "Loan Home"),
          TransactionCategory(id: 7, name: "Loan Student"),
          TransactionCategory(id: 8, name: "Loan Car"),
          TransactionCategory(id: 9, name: "Travel"),
          TransactionCategory(id: 10, name: "Gift"),
          TransactionCategory(id: 11, name: "Entertain"),
        ];

        // Sort list
        expenceCategoryList.sort((a, b) => a.name.compareTo(b.name));
      },
    );
    await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
  }

  Future<void> fetchIncomeCategoryList(BuildContext context) async {
    final failureOrUser = await _financeRepository.doSomething();
    failureOrUser.fold(
      (failure) {
        ViewModelUtil.handleFailure(
          context: context,
          failure: failure,
          showErrorSnackbar: false,
        );
      },
      (_) {
        incomeCategoryList = [
          TransactionCategory(id: 0, name: "Other"),
          TransactionCategory(id: 1, name: "Salary"),
          TransactionCategory(id: 2, name: "Sale"),
          TransactionCategory(id: 3, name: "Gift"),
          TransactionCategory(id: 6, name: "Loan Home"),
          TransactionCategory(id: 7, name: "Loan Student"),
          TransactionCategory(id: 8, name: "Loan Car"),
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

    final failureOrUser = await _financeRepository.doSomething();
    failureOrUser.fold(
      (failure) {
        ViewModelUtil.handleFailure(
          context: context,
          failure: failure,
        );
      },
      (_) {
        monthTransactionList = [
          Transaction(
            uuid: "1",
            amount: 2000000,
            timestamp: DateTime.now(),
            transactionType: TransactionType.income,
            category: TransactionCategory(id: 1, name: "Salary"),
          ),
          Transaction(
            uuid: "2",
            amount: -600000,
            timestamp: DateTime.now(),
            transactionType: TransactionType.expence,
            category: TransactionCategory(id: 3, name: "Rent"),
          ),
          Transaction(
            uuid: "3",
            amount: -40000,
            timestamp: DateTime.now(),
            transactionType: TransactionType.expence,
            category: TransactionCategory(id: 0, name: "Gas"),
          ),
        ];
      },
    );

    await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
  }

  Future<void> addTransaction(
      BuildContext context, Transaction transaction) async {
    _setState(_State.addingTransaction);

    final failureOrUser = await _financeRepository.doSomething();
    failureOrUser.fold(
      (failure) {
        ViewModelUtil.handleFailure(
          context: context,
          failure: failure,
        );
      },
      (_) {
        monthTransactionList.add(transaction);
      },
    );

    await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
    Navigator.of(context).pop();
  }
}
