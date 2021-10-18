import 'package:flutter/material.dart';
import 'package:live_free/data_models/transaction.dart';
import 'package:live_free/repositories/finance_repo.dart';
import 'package:live_free/view_models/utils_vm.dart';

enum _State { idle, busy, error }

class FinanceViewModel extends ChangeNotifier {
  final FinanceRepository _financeRepository;
  FinanceViewModel({
    required FinanceRepository financeRepository,
  }) : _financeRepository = financeRepository;

  _State _state = _State.busy;
  void _setState(_State viewState) {
    _state = viewState;
    notifyListeners();
  }

  List<Transaction> _monthTransactionList = const [];
  List<Transaction> get monthTransactionList => _monthTransactionList;

  bool get isBusy => _state == _State.busy;
  bool get hasError => _state == _State.error;

  Future<void> fetchMonthTransactions(BuildContext context) async {
    _setState(_State.busy);

    final failureOrUser = await _financeRepository.doSomething();
    failureOrUser.fold(
      (failure) {
        ViewModelUtil.handleFailure(
          context: context,
          failure: failure,
          logout: true,
        );
      },
      (_) {
        _monthTransactionList = [
          Transaction(
            uuid: "1",
            amount: 2000000,
            timestamp: DateTime.now(),
            transactionType: TransactionType.income,
            type: IncomeType.salary,
          ),
          Transaction(
            uuid: "2",
            amount: -600000,
            timestamp: DateTime.now(),
            transactionType: TransactionType.expence,
            type: ExpenceType.rent,
          ),
          Transaction(
            uuid: "3",
            amount: -40000,
            timestamp: DateTime.now(),
            transactionType: TransactionType.expence,
            type: ExpenceType.food,
          ),
        ];
      },
    );

    await Future.delayed(const Duration(milliseconds: 1000));
    _setState(_State.idle);
  }
}
