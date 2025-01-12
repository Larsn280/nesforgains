import 'package:flutter/material.dart';

class CustomBackNavigation {
  static Widget customBackNavigation({
    required BuildContext context,
    required Widget child,
  }) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Navigator.pushReplacementNamed(context, '/');
      },
      child: child,
    );
  }
}
