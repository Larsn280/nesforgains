import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class CustomSnackbar {
  static void showSnackBar({required String message}) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.black45),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
      ),
    );
  }
}
