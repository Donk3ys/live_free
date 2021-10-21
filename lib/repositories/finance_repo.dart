import 'package:fpdart/fpdart.dart';
import 'package:live_free/core/constants.dart';
import 'package:live_free/core/success.dart';
import 'package:live_free/data_models/saving.dart';
import 'package:live_free/data_models/transaction.dart';
import 'package:live_free/external_services/local_data_src.dart';
import 'package:live_free/external_services/remote_finance_src.dart';
import 'package:live_free/service_locator.dart';
import 'package:loggy/loggy.dart';

import 'utils_repo.dart';

class FinanceRepository with UiLoggy {
  final LocalDataSource _localDataSource;
  final RemoteFinanceSource _remoteFinanceSource;

  FinanceRepository({
    required LocalDataSource localDataSource,
    required RemoteFinanceSource remoteFinanceSource,
  })  : _localDataSource = localDataSource,
        _remoteFinanceSource = remoteFinanceSource;

  // FULL FUNCTIONS
  FailOr<Success> doSomething() async {
    try {
      return right(cacheSuccess);
    } catch (e, s) {
      return left(await RepoUtil.handleException(e, s));
    }
  }

  // NOTE: transactions

  FailOr<List<Transaction>> fetchTransactionHistory() async {
    try {
      final transHist = await _localDataSource.transactionHistory;
      return right(transHist);
    } catch (e, s) {
      return left(await RepoUtil.handleException(e, s));
    }
  }

  FailOr<Success> addTransaction(Transaction transaction) async {
    try {
      final success = await _localDataSource.storeTransaction(transaction);
      return right(success);
    } catch (e, s) {
      return left(await RepoUtil.handleException(e, s));
    }
  }

  FailOr<Success> removeTransaction(Transaction transaction) async {
    try {
      final success = await _localDataSource.removeTransaction(transaction);
      return right(success);
    } catch (e, s) {
      return left(await RepoUtil.handleException(e, s));
    }
  }

  // NOTE: savings

  FailOr<List<Saving>> fetchSavingList() async {
    try {
      final sList = await _localDataSource.savingList;
      return right(sList);
    } catch (e, s) {
      return left(await RepoUtil.handleException(e, s));
    }
  }

  FailOr<Success> addSaving(Saving saving) async {
    try {
      final success = await _localDataSource.storeSaving(saving);
      return right(success);
    } catch (e, s) {
      return left(await RepoUtil.handleException(e, s));
    }
  }

  FailOr<Success> removeSaving(Saving saving) async {
    try {
      final success = await _localDataSource.removeSaving(saving);
      return right(success);
    } catch (e, s) {
      return left(await RepoUtil.handleException(e, s));
    }
  }
}
