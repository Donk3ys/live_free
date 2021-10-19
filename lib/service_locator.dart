import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:live_free/external_services/network_info.dart';
import 'package:live_free/external_services/remote_finance_src.dart';
import 'package:live_free/repositories/finance_repo.dart';
import 'package:live_free/view_models/finance_vm.dart';
import 'package:loggy/loggy.dart';

import 'core/logging.dart';
import 'external_services/local_data_src.dart';
import 'view_models/network_vm.dart';
import 'view_models/theme_vm.dart';

final sl = GetIt.instance;

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
  // View Models
  sl.registerLazySingleton(() => NetworkViewModel(networkInfo: sl()));
  sl.registerLazySingleton(() => ThemeViewModel(localDataSource: sl()));
  sl.registerLazySingleton(() => TransactionViewModel(financeRepository: sl()));

  // Repositories
  sl.registerLazySingleton(
    () => FinanceRepository(
      localDataSource: sl(),
      remoteFinanceSource: sl(),
    ),
  );

  // Services
  sl.registerLazySingleton<LocalDataSource>(() => LocalDataSource(_hiveBox));
  final apiUrl = dotenv.env["SERVER_API_URL"];
  if (apiUrl == null) throw Exception("Could not find SERVER_API_URL in .env");
  sl.registerLazySingleton<RemoteFinanceSource>(
    () => RemoteFinanceSource(sl(), apiUrl),
  );
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(sl()),
  );

  // External
  sl.registerLazySingleton<Client>(() => Client());
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker(),
  );
}
