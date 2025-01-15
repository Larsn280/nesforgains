import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/screens/authScreens/login_screen.dart';
import 'package:nesforgains/screens/authScreens/register_screen.dart';
import 'package:nesforgains/screens/book_of_exuses.dart';
import 'package:nesforgains/screens/dishScreens/display_dishes_screen.dart';
import 'package:nesforgains/screens/display_scoreboard_screen.dart';
import 'package:nesforgains/screens/home_screen.dart';
import 'package:nesforgains/screens/nutritionScreens/display_daily_nutrition_screen.dart';
import 'package:nesforgains/screens/nutritionScreens/nutrition_screen.dart';
import 'package:nesforgains/screens/recipeScreens/display_recipe_screen.dart';
import 'package:nesforgains/screens/workoutScreens/display_workout_screen.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/secure_storage_service.dart'; // Import SecureStorageService
import 'package:nesforgains/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class App extends StatelessWidget {
  final Database sqflite;

  const App({super.key, required this.sqflite});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        Provider(create: (_) => SecureStorageService()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'NESForGains',
        theme: AppConstants.themeData,
        initialRoute: '/',
        routes: {
          '/': (context) {
            return FutureBuilder(
              future:
                  Provider.of<AuthState>(context, listen: false).initialize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final isLoggedIn =
                      Provider.of<AuthState>(context).checkLoginStatus();
                  return isLoggedIn
                      ? const HomeScreen()
                      : LoginScreen(sqflite: sqflite);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            );
          },
          '/homeScreen': (context) => const HomeScreen(),
          '/bookofexusesScreen': (context) => const BookOfExuses(),
          '/registerScreen': (context) => RegisterScreen(sqflite: sqflite),
          '/nutritionScreen': (context) => NutritionScreen(sqflite: sqflite),
          '/displaydishesScreen': (context) =>
              DisplayDishesScreen(sqflite: sqflite),
          '/displaynutritionScreen': (context) =>
              DisplayDailyNutritionScreen(sqflite: sqflite),
          '/displayworkoutScreen': (context) =>
              DisplayWorkoutScreen(sqflite: sqflite),
          '/displayrecipeScreen': (context) =>
              DisplayRecipeScreen(sqflite: sqflite),
          '/displayscoreboardScreen': (context) =>
              DisplayScoreboardScreen(sqflite: sqflite),
        },
      ),
    );
  }
}
