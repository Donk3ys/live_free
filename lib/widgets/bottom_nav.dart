import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrouter/vrouter.dart';

import '../core/constants.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        return BottomNavigationBar(
          backgroundColor: kColorCardDark,
          selectedItemColor: kColorAccent,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          unselectedItemColor: Colors.white,
          onTap: (index) async {
            if (currentIndex != 0 && index == 0) {
              context.vRouter.to("/");
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: currentIndex == 0 ? kColorAccent : Colors.white,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: currentIndex == 1 ? kColorAccent : Colors.white,
              ),
              label: "Home2",
            ),
          ],
        );
      },
    );
  }
}
