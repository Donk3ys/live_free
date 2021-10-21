import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_free/service_locator.dart';

import '../../core/constants.dart';
import '../view_models/theme_vm.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class NavDrawerButton extends StatelessWidget {
  const NavDrawerButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (ctx, watch, child) {
        //final themeVM = watch(themeVMProvider);
        return IconButton(
          splashRadius: 24.0,
          splashColor: kColorAccent,
          icon: const Icon(Icons.menu_outlined, color: kColorAccent),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        );
      },
    );
  }
}

class _NavDrawerState extends State<NavDrawer> {
  static const kNavHeight = 120.0;
  late ThemeViewModel _themeVm;

  double maxHeight = 100.0;
  int _sklarkDevCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        // Watch Providers
        final themeVM = watch(themeVMProvider);

        return LayoutBuilder(
          builder: (context, constraints) {
            maxHeight = constraints.maxHeight;
            return SizedBox(
              height: maxHeight,
              width: kDrawerWidth,
              child: Container(
                color: themeVM.isDarkMode ? kColorCardDark : kColorCardLight,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context
                            .findRootAncestorStateOfType<
                                DrawerControllerState>()
                            ?.close();
                      },
                      child: Container(
                        height: kNavHeight,
                        width: double.infinity,
                        color: kColorAccent,
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            CircleAvatar(
                              radius: 30,
                              child: Icon(Icons.face),
                            ),
                            SizedBox(height: 8.0),
                            Text("Full Name"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    _menuColumn(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    _themeVm = context.read(themeVMProvider);
    // Do after build
    WidgetsBinding.instance!.addPostFrameCallback((_) async {});
    super.initState();
  }

  Widget _menuColumn() {
    return Container(
      height: maxHeight - kNavHeight - 40.0,
      width: kDrawerWidth + 50,
      color: _themeVm.isDarkMode ? kColorCardDark : kColorCardLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
//           if (_authViewModel.isLoggedIn)
//             InkWell(
//               onTap: () async {
//                 context
//                     .findRootAncestorStateOfType<DrawerControllerState>()
//                     ?.close();
//                 // widget.scaffoldKey.currentState.close(direction: InnerDrawerDirection.end);
//                 // context.vRouter.push("/user");
//                 context.vRouter.to("/user-profile", isReplacement: true);
//                 // Routes.to(context, const UserPage());
//               },
//               child: Container(
//                 width: double.infinity,
//                 height: kDrawerMenuTileHeight,
//                 color: context.vRouter.url == "/user"
//                     ? kColorBackgroundDark
//                     : null,
//                 padding: kDrawerMenuTilePadding,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SizedBox(
//                       width: 160.0,
//                       child: Text(
//                         _authViewModel.currentUser.firstName,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     const Icon(Icons.account_circle, color: kColorAccent),
//                   ],
//                 ),
//               ),
//             ),
          // if (_authViewModel.isLoggedIn)
          InkWell(
            onTap: () async {
              context
                  .findRootAncestorStateOfType<DrawerControllerState>()
                  ?.close();
              // _authViewModel.logout();
            },
            child: Padding(
              padding: kDrawerMenuTilePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Logout"),
                  Icon(Icons.logout),
                ],
              ),
            ),
          ),
          kDrawerDivider,
          InkWell(
            onTap: () async {
              _themeVm.toggleMode();
            },
            child: Padding(
              padding: kDrawerMenuTilePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_themeVm.isDarkMode ? "Light Mode" : "Dark Mode"),
                  Icon(
                    _themeVm.isDarkMode
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_round,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () async {
                    context
                        .findRootAncestorStateOfType<DrawerControllerState>()
                        ?.close();
                    // context.vRouter.to("/contact");
                  },
                  child: Padding(
                    padding: kDrawerMenuTilePadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Contact Us"),
                        Icon(Icons.phone),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    context
                        .findRootAncestorStateOfType<DrawerControllerState>()
                        ?.close();
                    // context.vRouter.to("/terms-conditions");
                  },
                  child: Padding(
                    padding: kDrawerMenuTilePadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Terms & Conditions"),
                        Icon(Icons.file_copy),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () async {
                      _sklarkDevCounter++;
                      if (_sklarkDevCounter >= 7) {
                        _sklarkDevCounter = 0;
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            // title: const Text("Alert"),
                            content: const SizedBox(
                              width: 200,
                              child: Text("A Donk3y Development!"),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async =>
                                    Navigator.of(context).pop(),
                                child: const Text("Ok"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, left: 8.0),
                      child: Text(
                        kVersion,
                        style: TextStyle(color: Colors.grey, fontSize: 8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
