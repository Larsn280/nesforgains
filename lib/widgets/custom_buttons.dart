import 'package:flutter/material.dart';

class CustomButtons {
  static Widget buildElevatedFunctionButton({
    required BuildContext context,
    required Function() onPressed,
    required String text,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.50,
      child: ElevatedButton(
        onPressed: () {
          onPressed();
        },
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.white),
          backgroundColor:
              WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.grey; // Color when pressed
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.grey;
            }
            return Colors.black45;
          }),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Border radius
              side: const BorderSide(
                color: Colors.white, // Border color
                width: 1.0, // Border width
              ),
            ),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
