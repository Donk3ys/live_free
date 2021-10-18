import 'package:fpdart/fpdart.dart';
import 'package:live_free/core/constants.dart';
import 'package:live_free/external_services/local_data_src.dart';
import 'package:live_free/external_services/remote_finance_src.dart';
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
  FailOr<Unit> doSomething() async {
    try {
      return right(unit);
    } catch (e, s) {
      return left(await RepoUtil.handleException(e, s));
    }
  }
}
