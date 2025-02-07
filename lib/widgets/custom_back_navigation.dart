import 'package:flutter/material.dart';

class CustomBackNavigation extends StatelessWidget {
  final Widget child;

  const CustomBackNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
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
