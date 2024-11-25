import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/screens/authScreens/login_screen.dart';
import 'package:nesforgains/screens/authScreens/register_screen.dart';
import 'package:nesforgains/screens/home_screen.dart';
import 'package:nesforgains/screens/workoutScreens/display_workout_screen.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class App extends StatelessWidget {
  final Database sqflite;

  const App({super.key, required this.sqflite});

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
        child: MaterialApp(
            scaffoldMessengerKey: scaffoldMessengerKey,
            title: 'NESForGains',
            theme: AppConstants.themeData,
            initialRoute: '/',
            routes: {
          '/': (context) {
            final isLoggedIn =
                Provider.of<AuthState>(context).checkLoginStatus();
            return isLoggedIn
                ? const HomeScreen()
                : LoginScreen(
                    sqflite: sqflite,
                  );
          },
          '/homeScreen': (context) => const HomeScreen(),
          '/registerScreen': (context) => RegisterScreen(sqflite: sqflite),
          '/displayworkoutScreen': (context) =>
              DisplayWorkoutScreen(sqflite: sqflite)
        }));
  }
}
