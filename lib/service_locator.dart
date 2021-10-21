import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:live_free/core/success.dart';
import 'package:live_free/external_services/network_info.dart';
import 'package:live_free/external_services/remote_finance_src.dart';
import 'package:live_free/repositories/finance_repo.dart';
import 'package:live_free/view_models/transaction_vm.dart';
import 'package:loggy/loggy.dart';

import 'core/logging.dart';
import 'external_services/local_data_src.dart';
import 'view_models/network_vm.dart';
import 'view_models/theme_vm.dart';

final sl = GetIt.instance;

final cacheSuccess = CacheSuccess();
final serverSuccess = ServerSuccess();

// NOTE: Change notifiers
final transactionVmProvider = ChangeNotifierProvider<TransactionViewModel>(
  (ref) => sl(),
);
final networkVMProvider = ChangeNotifierProvider<NetworkViewModel>(
  (ref) => sl(),
);
final themeVMProvider = ChangeNotifierProvider<ThemeViewModel>(
  (ref) => sl(),
);

Future<void> initInjector() async {
  // Init .env
  await dotenv.load();

  // Init local storage
  await Hive.initFlutter();
  final _hiveBox = await Hive.openBox("hive");

  // Inti logging
  Loggy.initLoggy(
    logPrinter: CustomLogPrinter(),
    //logOptions: const LogOptions(LogLevel.all, stackTraceLevel: LogLevel.off)
  );

  // NOTE: View Models
  sl.registerLazySingleton(() => NetworkViewModel(networkInfo: sl()));
  sl.registerLazySingleton(() => ThemeViewModel(localDataSource: sl()));
  sl.registerLazySingleton(() => TransactionViewModel(financeRepository: sl()));

  // NOTE: Repositories
  sl.registerLazySingleton(
    () => FinanceRepository(
      localDataSource: sl(),
      remoteFinanceSource: sl(),
    ),
  );

  // NOTE: Services
  sl.registerLazySingleton<LocalDataSource>(() => LocalDataSource(_hiveBox));
  final apiUrl = dotenv.env["SERVER_API_URL"];
  if (apiUrl == null) throw Exception("Could not find SERVER_API_URL in .env");
  sl.registerLazySingleton<RemoteFinanceSource>(
    () => RemoteFinanceSource(sl(), apiUrl),
  );
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(sl()),
  );

  // NOTE: External
  sl.registerLazySingleton<Client>(() => Client());
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker(),
  );
}
