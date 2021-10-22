import 'package:flutter/material.dart';

import '../core/constants.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String bodyText;
  const ConfirmDeleteDialog({Key? key, required this.bodyText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.error_outline),
          SizedBox(width: 16.0),
          Text("Confirm Delete"),
        ],
      ),
      content: SizedBox(
        width: 260.0,
        child: Text(bodyText),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            "Cancel",
            style: TextStyle(color: kColorSecondaryText),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            "Delete",
          ),
        ),
      ],
    );
  }
}
