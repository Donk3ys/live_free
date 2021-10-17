import 'package:flutter/material.dart';
import '../core/constants.dart';

class OfflineWidget extends StatelessWidget {
  const OfflineWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 60.0,
      child: Container(
        height: 40.0,
        width: 110.0,
        color: kColorError,
        child: const Center(
          child: Text("Offline"),
        ),
      ),
    );
  }
}
