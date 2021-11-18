import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_free/core/constants.dart';
import 'package:live_free/service_locator.dart';
import 'package:live_free/widgets/pages/all_transactions_pg.dart';
import 'package:live_free/widgets/pages/home_pg.dart';
import 'package:live_free/widgets/pages/transaction_type_pg.dart';
import 'package:vrouter/vrouter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // GetIt -> Setup dependency injetion
  await initInjector();

  // Get Theme
  await themeVm.getThemeModeFromStorage();

  // Adding ProviderScope enables Riverpod for the entire project
  runApp(ProviderScope(child: App()));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        watch(themeVMProvider);

        return VRouter(
          title: "Sportee",
          logs: VLogs.none,
          debugShowCheckedModeBanner: false,
          theme: themeVm.isDarkMode ? themeVm.dark : themeVm.light,
          routes: [
            // VWidget(path: '/', widget: const TestPage(),
            VWidget(
              path: kHomeRoute,
              widget: const HomePage(),
              buildTransition: (a, _, child) =>
                  FadeTransition(opacity: a, child: child),
            ),

            VPopHandler(
              onPop: (router) async {
                if (router.historyCanBack()) {
                  router.historyBack();
                } else {
                  router.to(kHomeRoute);
                }
              },
              onSystemPop: (router) async {
                if (router.historyCanBack()) {
                  router.historyBack();
                } else {
                  router.to(kHomeRoute);
                }
              },
              stackedRoutes: [
                // Profile
                VWidget(
                  path: kMonthTransactionsRoute,
                  widget: const TransactionHistoryPage(),
                  buildTransition: (a, _, child) =>
                      FadeTransition(opacity: a, child: child),
                ),
                VWidget(
                  path: kAllTransactionsRoute,
                  widget: const AllTransactionHistoryPage(),
                  buildTransition: (a, _, child) =>
                      FadeTransition(opacity: a, child: child),
                ),
              ],
            ),

            // Legal
//             VWidget(
//               path: '/terms-conditions',
//               widget: const TermsConditionsPage(),
//               buildTransition: (a, _, child) =>
//                   FadeTransition(opacity: a, child: child),
//             ),
//             VWidget(
//               path: '/contact',
//               widget: const ContactPage(),
//               buildTransition: (a, _, child) =>
//                   FadeTransition(opacity: a, child: child),
//             ),
//              VWidget(path: '/error', widget: ErrorPage(),
//                buildTransition: (animation1, _, child) {
//                  return FadeTransition(opacity: animation1, child: child);
//                },
//              ),
//
//              VRouteRedirector(
//                path: ':_(.*)',
//                redirectTo: '/error',
//              ),
          ],
        );
      },
    );
  }
}
