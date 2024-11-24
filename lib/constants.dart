import 'package:flutter/material.dart';

class AppConstants {
  static const String appbackgroundimage = 'assets/the-incredible-hulk.webp';
  static const Color primaryColor = Colors.green;
  static Color primaryTextColor = Colors.white.withOpacity(0.9);

  static const TextStyle headingStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 26.0,
    color: Colors.white,
  );
  static const TextStyle subheadingStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
    color: Colors.white,
  );

  static ThemeData themeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppConstants.primaryTextColor,
        selectionColor: AppConstants.primaryTextColor,
        selectionHandleColor: AppConstants.primaryTextColor),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: AppConstants.primaryTextColor),
      labelStyle: TextStyle(color: AppConstants.primaryTextColor),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppConstants.primaryTextColor),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppConstants.primaryTextColor),
      ),
    ),
    textTheme: TextTheme(
      bodySmall: TextStyle(color: AppConstants.primaryTextColor),
      bodyMedium: TextStyle(color: AppConstants.primaryTextColor),
      bodyLarge: TextStyle(color: AppConstants.primaryTextColor),
    ),
    useMaterial3: true,
  );
}
