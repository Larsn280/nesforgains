import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/dish.dart';
import 'package:nesforgains/models/response_data.dart';
import 'package:sqflite/sqflite.dart';

class DishService {
  final Database _sqflite;

  DishService(this._sqflite);

  Future<List<Dish>> fetchAllDishesById(String userId) async {
    try {
      // Query the dishes for the given userId
      final dishData = await _sqflite.query(
        'Dish',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      // Return early if no dishes are found
      if (dishData.isEmpty) {
        return []; // Returning an empty list
      }

      // Transforming the dish data into Nutrition objects
      List<Dish> allDishItems = dishData.map((dish) {
        return Dish(
          dish: dish['name'] as String,
          calories: dish['calories'] as int? ?? 0,
          protein: dish['protein'] as int? ?? 0,
          carbohydrates: dish['carbohydrates'] as int? ?? 0,
          fat: dish['fat'] as int? ?? 0,
        );
      }).toList();

      // Sorting the dish items by name
      allDishItems.sort((a, b) => a.dish!.compareTo(b.dish!));

      return allDishItems;
    } catch (e) {
      // Log the error and return an empty list
      logger.e('Error trying to fetch dishes: ${e.toString()}');
      return []; // Returning an empty list on error
    }
  }

  Future<List<String>> fetchAllDishNamesById(String userId) async {
    try {
      // Query the Dish table by userId
      final dishData = await _sqflite.query(
        'Dish',
        where: 'userId = ?',
        whereArgs: [userId],
        columns: ['name'], // Only fetch the name column
      );

      // Return an empty list if no dishes are found
      if (dishData.isEmpty) {
        logger.i('No items found in the dish table.');
        return []; // Returning an empty list
      }

      // Extracting dish names using map
      List<String> dishItemNames = dishData.map((dish) {
        return dish['name'] as String;
      }).toList();

      return dishItemNames;
    } catch (e) {
      logger.e('Error fetching food items', error: e);
      return []; // Returning an empty list on error
    }
  }

  Future<ResponseData> addDish(Dish data, String userId) async {
    try {
      // Query the Dish table to check if the dish already exists
      final existingDish = await _sqflite.query(
        'Dish',
        where: 'name = ? AND userId = ?',
        whereArgs: [data.dish, userId],
      );

      // If the dish does not exist, create a new one
      if (existingDish.isEmpty) {
        final newDish = {
          'name': data.dish,
          'calories': data.calories!.toInt(),
          'protein': data.protein!.toInt(),
          'carbohydrates': data.carbohydrates!.toInt(),
          'fat': data.fat!.toInt(),
          'userId': userId,
        };

        // Insert the new dish into the Dish table
        await _sqflite.insert('Dish', newDish);

        return ResponseData(
          checksuccess: true,
          message: '${data.dish} was successfully added!',
        );
      } else {
        // If the dish already exists, return a failure response
        return ResponseData(
          checksuccess: false,
          message: '${data.dish} already exists',
        );
      }
    } catch (e) {
      // Log the error and return a response indicating failure
      return ResponseData(
        checksuccess: false,
        message: 'Error trying to add dish: ${e.toString()}',
      );
    }
  }

  Future<ResponseData> deleteDish(String name, String userId) async {
    try {
      // Check if the dish name is provided
      if (name.isEmpty) {
        return ResponseData(
          checksuccess: false,
          message: 'Dish name cannot be empty.',
        );
      }

      // Query the Dish table to find the dish by name and userId
      final dishToDelete = await _sqflite.query(
        'Dish',
        where: 'name = ? AND userId = ?',
        whereArgs: [name, userId],
      );

      // If the dish is found, proceed to delete
      if (dishToDelete.isNotEmpty) {
        // Get the id of the dish to delete
        final dishId = dishToDelete.first['id'] as int;

        // Delete the dish from the table
        await _sqflite.delete(
          'Dish',
          where: 'id = ?',
          whereArgs: [dishId],
        );

        return ResponseData(
          checksuccess: true,
          message: '$name was deleted!',
        );
      }

      // If the dish was not found, return a failure response
      return ResponseData(
        checksuccess: false,
        message: 'Could not find: $name to delete',
      );
    } catch (e) {
      // Log the error and return a failure response
      return ResponseData(
        checksuccess: false,
        message: 'Error trying to delete dish: ${e.toString()}',
      );
    }
  }

  Future<ResponseData> editDish(
      Dish dishData, String oldDishName, String userId) async {
    try {
      // Early return if the new dish name is empty
      if (dishData.dish == '') {
        return ResponseData(
            checksuccess: false, message: 'New dish name cannot be empty.');
      }

      // Query the Dish table to find the dish to edit by oldDishName and userId
      final dishToEdit = await _sqflite.query(
        'Dish',
        where: 'name = ? AND userId = ?',
        whereArgs: [oldDishName, userId],
      );

      // If the dish is found, update its properties
      if (dishToEdit.isNotEmpty) {
        final dishId = dishToEdit.first['id'] as int;

        // Prepare the updated dish data
        final updatedDish = {
          'name': dishData.dish,
          'calories': dishData.calories!.toInt(),
          'protein': dishData.protein!.toInt(),
          'carbohydrates': dishData.carbohydrates!.toInt(),
          'fat': dishData.fat!.toInt(),
        };

        // Update the dish in the table
        await _sqflite.update(
          'Dish',
          updatedDish,
          where: 'id = ?',
          whereArgs: [dishId],
        );

        return ResponseData(
            checksuccess: true,
            message: '${dishData.dish} was edited successfully.');
      }

      // If the dish was not found, return a failure response
      return ResponseData(
          checksuccess: false, message: 'Could not find: $oldDishName to edit');
    } catch (e) {
      // Log the error and return a failure response
      return ResponseData(
          checksuccess: false,
          message: 'Error trying to edit dish: ${e.toString()}');
    }
  }
}
