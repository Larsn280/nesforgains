import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/widgets/custom_navigation_menu.dart';

class CustomAppContainer extends StatelessWidget {
  final String titleText;
  final Widget child;

  const CustomAppContainer({
    super.key,
    required this.titleText,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.white,
            height: 1.0,
          ),
        ),
        title: Text(
          titleText,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const CustomNavigationMenu(),
      ),
      body: SizedBox.expand(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppConstants.appbackgroundimage),
                fit: BoxFit.cover),
          ),
          child: SingleChildScrollView(
            child: child,
          ),
        ),
      ),
    );
  }
}
