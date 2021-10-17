import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../main.dart';

class SliverCircularLoading extends StatelessWidget {
  final bool hasBackground;
  const SliverCircularLoading({Key? key, this.hasBackground = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final themeVM = watch(themeVMProvider);

        return SliverFillRemaining(
          child: Center(
            child: hasBackground
                ? CircleAvatar(
                    backgroundColor: themeVM.isDarkMode
                        ? kColorBackgroundDark
                        : kColorBackgroundLight,
                    radius: 40,
                    child: const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  )
                : const CircularProgressIndicator(strokeWidth: 3),
          ),
        );
      },
    );
  }
}

class LoadingWidget extends StatelessWidget {
  final bool hasBackground;
  const LoadingWidget({Key? key, this.hasBackground = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final themeVM = watch(themeVMProvider);

        return Center(
          child: hasBackground
              ? CircleAvatar(
                  backgroundColor: themeVM.isDarkMode
                      ? kColorBackgroundDark
                      : kColorBackgroundLight,
                  radius: 40,
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                )
              : const CircularProgressIndicator(strokeWidth: 3),
        );
      },
    );
  }
}

