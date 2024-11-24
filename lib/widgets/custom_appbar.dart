import 'package:flutter/material.dart';
import 'package:nesforgains/widgets/custom_navigation_menu.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize; // This is required to satisfy PreferredSizeWidget
  final String title;

  const CustomAppbar({super.key, required this.title})
      : preferredSize =
            const Size.fromHeight(60.0); // Adjust the height as needed

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      backgroundColor: Colors.black45,
      shape: const Border(
        bottom: BorderSide(color: Colors.white, width: 1.0),
      ),
      centerTitle: true,
      actions: const [],
      leading: const CustomNavigationMenu(),
      elevation: 4.0,
    );
  }
}
