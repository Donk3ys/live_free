import 'package:live_free/core/success.dart';
import 'package:live_free/data_models/saving.dart';
import 'package:live_free/data_models/transaction.dart';
import 'package:live_free/external_services/local_data_src.dart';
import 'package:live_free/external_services/remote_finance_src.dart';
import 'package:live_free/service_locator.dart';
import 'package:loggy/loggy.dart';

class FinanceRepository with UiLoggy {
  final LocalDataSource _localDataSource;
  final RemoteFinanceSource _remoteFinanceSource;

  FinanceRepository({
    required LocalDataSource localDataSource,
    required RemoteFinanceSource remoteFinanceSource,
  })  : _localDataSource = localDataSource,
        _remoteFinanceSource = remoteFinanceSource;

  // FULL FUNCTIONS
  Future<Success> doSomething() async => cacheSuccess;
  // NOTE: transactions

  Future<List<Transaction>> fetchTransactionHistory() async =>
      _localDataSource.transactionHistory;
  Future<Success> addTransaction(Transaction transaction) async =>
      _localDataSource.storeTransaction(transaction);
  Future<Success> removeTransaction(Transaction transaction) async =>
      _localDataSource.removeTransaction(transaction);

  // NOTE: savings

  Future<List<Saving>> fetchSavingList() async => _localDataSource.savingList;
  Future<Success> addSaving(Saving saving) async =>
      _localDataSource.storeSaving(saving);
  Future<Success> removeSaving(Saving saving) async =>
      _localDataSource.removeSaving(saving);

//   FailOr<Success> removeSaving(Saving saving) async =>
//       _makeCall((_) => _localDataSource.removeSaving(saving));
//
//   FailOr<T> _makeCall<T>(Function(T) caller) async {
//     try {
//       final type = caller as T;
//       return right(type);
//     } catch (e, s) {
//       return left(await RepoUtil.handleException(e, s));
//     }
//   }
}
