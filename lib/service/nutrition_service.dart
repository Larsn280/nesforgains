import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/nutrition.dart';
import 'package:nesforgains/models/response_data.dart';
import 'package:sqflite/sqflite.dart';

class NutritionService {
  final Database _sqflite;

  NutritionService(this._sqflite);

  Future<Nutrition> fetchDailyNutritionById(String userId) async {
    try {
      // Get the current date (set the time to 00:00:00)
      final currentDate = DateTime.now();
      final currentDay =
          DateTime(currentDate.year, currentDate.month, currentDate.day);

      // Query the Nutrition table for the given userId and date
      final nutritionItems = await _sqflite.query(
        'Nutrition',
        where: 'userId = ? AND date = ?',
        whereArgs: [userId, currentDay.toIso8601String()],
      );

      // If a record exists, return the first one
      if (nutritionItems.isNotEmpty) {
        final intake = nutritionItems.first;

        return Nutrition(
          id: intake['id'] as int,
          date: intake['date'] as String,
          calories: intake['calories'] as int,
          protein: intake['protein'] as int,
          carbohydrates: intake['carbohydrates'] as int,
          fat: intake['fat'] as int,
          userId: intake['userId'] as String,
        );
      }

      // Return default nutrition data if no record is found
      return Nutrition(
        id: 0,
        date: currentDay.toIso8601String(),
        calories: 0,
        protein: 0,
        carbohydrates: 0,
        fat: 0,
        userId: userId,
      );
    } catch (e) {
      // Log the error and return default Nutrition data
      logger.e('Error fetching daily nutrition: ${e.toString()}');
      return Nutrition(
        id: 0,
        date: DateTime.now().toIso8601String(),
        calories: 0,
        protein: 0,
        carbohydrates: 0,
        fat: 0,
        userId: userId,
      );
    }
  }

  Future<List<Nutrition>> fetchNutritionListByUserId(String userId) async {
    try {
      // Query the Nutrition table for all entries with the given userId
      final nutritionItems = await _sqflite.query(
        'Nutrition',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      // If no data is found, return an empty list
      if (nutritionItems.isEmpty) {
        return [];
      }

      // Map the fetched data to Nutrition objects
      List<Nutrition> nutritionList = nutritionItems.map((item) {
        return Nutrition(
          id: item['id'] as int,
          date: item['date'] as String,
          calories: item['calories'] as int,
          protein: item['protein'] as int,
          carbohydrates: item['carbohydrates'] as int,
          fat: item['fat'] as int,
          userId: item['userId'] as String,
        );
      }).toList();

      // Return the mapped list of Nutrition objects
      return nutritionList;
    } catch (e) {
      // Log the error if you have a logging mechanism
      logger.e('Error fetching nutrition list for user $userId', error: e);

      // Return an empty list to indicate failure
      return [];
    }
  }

  Future<ResponseData> postDailyDish(String dish, String userId) async {
    try {
      // Fetch the dish item from the dish table for the given userId
      final dishItems = await _sqflite.query(
        'Dish',
        where: 'name = ? AND userId = ?',
        whereArgs: [dish, userId],
      );

      // Check if the dish item exists
      if (dishItems.isEmpty) {
        return ResponseData(checksuccess: false, message: 'Invalid input');
      }

      final dishItem = dishItems.first; // Assuming only one dish with that name

      // Get the current date and set time components to 0
      final currentDate = DateTime.now();
      final currentDay =
          DateTime(currentDate.year, currentDate.month, currentDate.day);

      // Check if there is already an entry for the current day in the dailyNutritions table
      final dailyNutritionItems = await _sqflite.query(
        'Nutrition',
        where: 'userId = ? AND date = ?',
        whereArgs: [userId, currentDay.toIso8601String()],
      );

      int getIntValue(Object? value) {
        return value is int ? value : 0;
      }

      if (dailyNutritionItems.isNotEmpty) {
        // Update existing daily nutrition
        final currentDailyNutrition = dailyNutritionItems.first;

        int newCalories = getIntValue(currentDailyNutrition['calories']) +
            getIntValue(dishItem['calories']);
        int newProtein = getIntValue(currentDailyNutrition['protein']) +
            getIntValue(dishItem['protein']);
        int newCarbohydrates =
            getIntValue(currentDailyNutrition['carbohydrates']) +
                getIntValue(dishItem['carbohydrates']);
        int newFat = getIntValue(currentDailyNutrition['fat']) +
            getIntValue(dishItem['fat']);

        // Update the daily nutrition record
        await _sqflite.update(
          'Nutrition',
          {
            'calories': newCalories,
            'protein': newProtein,
            'carbohydrates': newCarbohydrates,
            'fat': newFat,
          },
          where: 'userId = ? AND date = ?',
          whereArgs: [userId, currentDay.toIso8601String()],
        );
      } else {
        // If no record exists for the current day, create a new one
        await _sqflite.insert(
          'Nutrition',
          {
            'date': currentDay.toIso8601String(),
            'calories': dishItem['calories'],
            'protein': dishItem['protein'],
            'carbohydrates': dishItem['carbohydrates'],
            'fat': dishItem['fat'],
            'userId': userId,
          },
        );
      }

      // Return success message
      return ResponseData(
        checksuccess: true,
        message: '$dish was added to your intake!',
      );
    } catch (e) {
      // Log the error if necessary
      return ResponseData(
        checksuccess: false,
        message: 'Error when trying to add intake: ${e.toString()}',
      );
    }
  }

  Future<ResponseData> putDailyDish(String dish, String userId) async {
    try {
      // Fetch the dish item from the Dish table for the given userId
      final dishItems = await _sqflite.query(
        'Dish',
        where: 'name = ? AND userId = ?',
        whereArgs: [dish, userId],
      );

      // Check if the dish item exists
      if (dishItems.isEmpty) {
        return ResponseData(checksuccess: false, message: 'Invalid input');
      }

      final dishItem = dishItems.first; // Assuming only one dish with that name

      // Get the current date and set time components to 0
      final currentDate = DateTime.now();
      final currentDay =
          DateTime(currentDate.year, currentDate.month, currentDate.day);

      // Attempt to fetch current daily nutrition for the user
      final dailyNutritionItems = await _sqflite.query(
        'Nutrition',
        where: 'userId = ? AND date = ?',
        whereArgs: [userId, currentDay.toIso8601String()],
      );

      int getIntValue(Object? value) {
        return value is int ? value : 0;
      }

      // Function to subtract and ensure nutrition does not go negative
      int checkNutrition(int nutrition, int subtractedNutrition) {
        return (nutrition - subtractedNutrition).clamp(0, nutrition);
      }

      if (dailyNutritionItems.isNotEmpty) {
        // If a daily nutrition record exists, subtract the dish's values
        final currentDailyNutrition = dailyNutritionItems.first;

        int newCalories = checkNutrition(
            getIntValue(currentDailyNutrition['calories']),
            getIntValue(dishItem['calories']));
        int newProtein = checkNutrition(
            getIntValue(currentDailyNutrition['protein']),
            getIntValue(dishItem['protein']));
        int newCarbohydrates = checkNutrition(
            getIntValue(currentDailyNutrition['carbohydrates']),
            getIntValue(dishItem['carbohydrates']));
        int newFat = checkNutrition(getIntValue(currentDailyNutrition['fat']),
            getIntValue(dishItem['fat']));

        // Update the daily nutrition record in the database
        await _sqflite.update(
          'Nutrition',
          {
            'calories': newCalories,
            'protein': newProtein,
            'carbohydrates': newCarbohydrates,
            'fat': newFat,
          },
          where: 'userId = ? AND date = ?',
          whereArgs: [userId, currentDay.toIso8601String()],
        );

        return ResponseData(
            checksuccess: true, message: '$dish was removed from your intake!');
      } else {
        // If no daily nutrition record exists, create a new one with zero values
        await _sqflite.insert(
          'Nutrition',
          {
            'date': currentDay.toIso8601String(),
            'calories': 0, // Start at 0 since we are removing intake
            'protein': 0,
            'carbohydrates': 0,
            'fat': 0,
            'userId': userId,
          },
        );

        return ResponseData(
            checksuccess: true, message: '$dish was removed from your intake!');
      }
    } catch (e) {
      // Log the error if necessary
      return ResponseData(
          checksuccess: false,
          message: 'Error while trying to remove intake: ${e.toString()}');
    }
  }
}
