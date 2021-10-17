import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_free/service_locator.dart';
import 'package:live_free/view_models/finance_vm.dart';
import 'package:live_free/view_models/network_vm.dart';
import 'package:live_free/view_models/theme_vm.dart';
import 'package:live_free/widgets/pages/home_pg.dart';
import 'package:vrouter/vrouter.dart';

// Setup view model providers
final financeVmProvider = ChangeNotifierProvider<FinanceViewModel>(
  (ref) => sl(),
);
final networkVMProvider = ChangeNotifierProvider<NetworkViewModel>(
  (ref) => sl(),
);
final themeVMProvider = ChangeNotifierProvider<ThemeViewModel>(
  (ref) => sl(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // GetIt -> Setup dependency injetion
  await initInjector();

  // Get Theme
  await sl<ThemeViewModel>().getThemeModeFromStorage();

  // Adding ProviderScope enables Riverpod for the entire project
  runApp(ProviderScope(child: App()));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final themeVM = watch(themeVMProvider);
        return VRouter(
          title: "Sportee",
          logs: VLogs.none,
          debugShowCheckedModeBanner: false,
          theme: themeVM.isDarkMode ? themeVM.dark : themeVM.light,
          routes: [
            // VWidget(path: '/', widget: const TestPage(),
            VWidget(
              path: '/',
              widget: const HomePage(),
              buildTransition: (a, _, child) =>
                  FadeTransition(opacity: a, child: child),
            ),

            VPopHandler(
              onPop: (router) async {
                if (router.historyCanBack()) {
                  router.historyBack();
                } else {
                  router.to("/");
                }
              },
              onSystemPop: (router) async {
                if (router.historyCanBack()) {
                  router.historyBack();
                } else {
                  router.to("/");
                }
              },
              stackedRoutes: [
                // Profile
                VWidget(
                  path: '/expences',
                  widget: const Placeholder(),
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
