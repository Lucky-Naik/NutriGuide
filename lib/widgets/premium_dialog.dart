import 'package:flutter/material.dart';

void showPremiumDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Premium Feature 🔒"),
      content: Text(
        "This recipe is available for Premium users only.\n\nUpgrade to unlock exclusive recipes.",
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text("Upgrade"),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, "/premium");
          },
        ),
      ],
    ),
  );
}
