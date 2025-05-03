import 'package:flutter/material.dart';

void showAlert(BuildContext context, String title, String message,
    void Function()? onPressed) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the alert
              onPressed!();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
