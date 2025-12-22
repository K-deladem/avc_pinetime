import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  /// Custom Back labelLarge with a custom ICON for this app
  const AppBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon:  const Icon(Icons.arrow_back_ios_new),
      onPressed: () => Navigator.pop(context),
    );
  }
}
