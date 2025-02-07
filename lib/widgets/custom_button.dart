import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final Function() onPressed;

  const CustomButton({
    super.key,
    required this.text,
    this.width = 150,
    this.height = 40,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(width, height)),
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
          // padding: const WidgetStatePropertyAll(
          //     EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
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
        child: Text(text));
  }
}
