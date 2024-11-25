import 'package:flutter/material.dart';

class CustomCheckBoxes {
  static Widget buildCheckBox({
    required BuildContext context,
    required bool isChecked,
    required VoidCallback onToggle,
    required IconData icon,
    required Color color,
  }) {
    return Checkbox(
      fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.grey; // Color when pressed
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.grey;
        }
        return Colors.black45;
      }),
      checkColor: color,
      value: isChecked,
      onChanged: (bool? value) {
        if (value != null) {
          onToggle();
        }
      },
      side: const BorderSide(
        color: Colors.white,
        width: 0.5,
      ),
    );
  }
}
