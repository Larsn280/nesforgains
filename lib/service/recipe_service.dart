import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/ingredient.dart';
import 'package:nesforgains/models/recipe.dart';
import 'package:nesforgains/models/response_data.dart';
import 'package:nesforgains/models/stage.dart';
import 'package:sqflite/sqflite.dart';

class RecipeService {
  final Database _sqflite;

  RecipeService(this._sqflite);

  Future<ResponseData> addRecipe(
      Recipe recipe, List<Ingredient> ingredients, List<Stage> stages) async {
    try {
      // Check if the recipe already exists
      final existingRecipes = await _sqflite.query(
        'Recipe',
        where: 'title = ?',
        whereArgs: [recipe.title],
      );

      if (existingRecipes.isEmpty) {
        // Start a transaction to ensure data integrity
        await _sqflite.transaction((txn) async {
          // Insert the recipe into the Recipe table
          final recipeId = await txn.insert(
            'Recipe',
            {
              'title': recipe.title,
              'description': recipe.description,
              'duration': recipe.duration,
              'difficulty': recipe.difficulty,
              'createdAt': recipe.createdAt,
              'updatedAt': recipe.updatedAt,
            },
          );

          // Insert ingredients into the Ingredient table
          for (final ingredient in ingredients) {
            await txn.insert(
              'Ingredient',
              {
                'recipeId': recipeId,
                'name': ingredient.name,
                'unit': ingredient.unit,
                'quantity': ingredient.quantity,
                'note': ingredient.note,
              },
            );
          }

          // Insert stages into the Stage table
          for (final stage in stages) {
            await txn.insert(
              'Stage',
              {
                'recipeId': recipeId,
                'stageNumber': stage.stageNumber,
                'instruction': stage.instruction,
                'duration': stage.duration,
              },
            );
          }
        });

        return ResponseData(
          checksuccess: true,
          message: 'Successfully added recipe: ${recipe.title}',
        );
      }

      // If recipe already exists, respond accordingly
      return ResponseData(
        checksuccess: false,
        message: 'Recipe already exists: ${recipe.title}',
      );
    } catch (e) {
      return ResponseData(
        checksuccess: false,
        message:
            'An error occurred while trying to add the recipe: ${e.toString()}',
      );
    }
  }

  Future<ResponseData> editRecipe(Recipe recipe,
      List<Ingredient> newIngredients, List<Stage> newStages) async {
    try {
      // Check if the recipe exists
      final existingRecipes = await _sqflite.query(
        'Recipe',
        where: 'id = ?',
        whereArgs: [recipe.id],
      );

      if (existingRecipes.isNotEmpty) {
        // Begin a transaction
        await _sqflite.transaction((txn) async {
          // Delete old ingredients and stages associated with the recipe
          await txn.delete(
            'Ingredient',
            where: 'recipeId = ?',
            whereArgs: [recipe.id],
          );

          await txn.delete(
            'Stage',
            where: 'recipeId = ?',
            whereArgs: [recipe.id],
          );

          // Insert new ingredients
          for (final ingredient in newIngredients) {
            await txn.insert(
              'Ingredient',
              {
                'recipeId': recipe.id,
                'name': ingredient.name,
                'unit': ingredient.unit,
                'quantity': ingredient.quantity,
                'note': ingredient.note,
              },
            );
          }

          // Insert new stages
          for (final stage in newStages) {
            await txn.insert(
              'Stage',
              {
                'recipeId': recipe.id,
                'stageNumber': stage.stageNumber,
                'instruction': stage.instruction,
                'duration': stage.duration,
              },
            );
          }

          // Update the recipe itself
          await txn.update(
            'Recipe',
            {
              'title': recipe.title,
              'description': recipe.description,
              'duration': recipe.duration,
              'difficulty': recipe.difficulty,
              'updatedAt': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [recipe.id],
          );
        });

        return ResponseData(
          checksuccess: true,
          message: '${recipe.title} was edited successfully.',
        );
      }

      return ResponseData(
        checksuccess: false,
        message: 'Recipe not found for editing.',
      );
    } catch (e) {
      logger.e('Error editing recipe: $e');
      return ResponseData(
        checksuccess: false,
        message: 'Error editing recipe: $e',
      );
    }
  }

  Future<ResponseData> deleteRecipe(Recipe recipe) async {
    try {
      // Check if the recipe exists
      final existingRecipes = await _sqflite.query(
        'Recipe',
        where: 'id = ? AND title = ?',
        whereArgs: [recipe.id, recipe.title],
      );

      if (existingRecipes.isNotEmpty) {
        // Perform the deletion
        await _sqflite.delete(
          'Recipe',
          where: 'id = ? AND title = ?',
          whereArgs: [recipe.id, recipe.title],
        );

        return ResponseData(
          checksuccess: true,
          message: '${recipe.title} was deleted.',
        );
      }

      return ResponseData(
        checksuccess: false,
        message: 'Could not find ${recipe.title} to delete.',
      );
    } catch (e) {
      logger.e('Error during recipe deletion: $e');
      return ResponseData(
        checksuccess: false,
        message: 'Error trying to delete recipe: $e',
      );
    }
  }

  Future<List<Recipe>> getAllRecipesInAlphabeticalOrder() async {
    try {
      // Query all recipes sorted alphabetically by title
      final recipesData = await _sqflite.query(
        'Recipe',
        orderBy: 'title ASC',
      );

      // Initialize a list to store Recipe objects
      List<Recipe> recipes = [];

      for (var recipeData in recipesData) {
        // Fetch ingredients for the recipe
        final ingredientsData = await _sqflite.query(
          'Ingredient',
          where: 'recipeId = ?',
          whereArgs: [recipeData['id']],
        );

        // Fetch stages for the recipe
        final stagesData = await _sqflite.query(
          'Stage',
          where: 'recipeId = ?',
          whereArgs: [recipeData['id']],
        );

        // Convert ingredientsData and stagesData into objects
        final ingredients = ingredientsData.map((data) {
          return Ingredient(
            id: data['id'] as int,
            recipeId: data['recipeId'] as int,
            name: data['name'] as String,
            unit: data['unit'] as String?,
            quantity: data['quantity'] as double?,
            note: data['note'] as String?,
          );
        }).toList();

        final stages = stagesData.map((data) {
          return Stage(
            id: data['id'] as int,
            recipeId: data['recipeId'] as int,
            stageNumber: data['stageNumber'] as int?,
            instruction: data['instruction'] as String?,
            duration: data['duration'] as int?,
          );
        }).toList();

        // Create the Recipe object
        recipes.add(Recipe(
          id: recipeData['id'] as int,
          title: recipeData['title'] as String,
          description: recipeData['description'] as String?,
          duration: recipeData['duration'] as int?,
          difficulty: recipeData['difficulty'] as String?,
          createdAt: recipeData['createdAt'] as String?,
          updatedAt: recipeData['updatedAt'] as String?,
          ingredients: ingredients,
          stages: stages,
        ));
      }

      return recipes;
    } catch (e) {
      logger.e('Error fetching recipes: $e');
      throw Exception('Error while retrieving recipes');
    }
  }

  Future<Recipe> fetchRecipeById(int recipeId) async {
    try {
      // Fetch the recipe by ID
      final recipeData = await _sqflite.query(
        'Recipe',
        where: 'id = ?',
        whereArgs: [recipeId],
      );

      if (recipeData.isEmpty) {
        throw Exception('Recipe not found for ID $recipeId');
      }

      // Fetch the associated ingredients
      final ingredientsData = await _sqflite.query(
        'Ingredient',
        where: 'recipeId = ?',
        whereArgs: [recipeId],
      );

      // Fetch the associated stages
      final stagesData = await _sqflite.query(
        'Stage',
        where: 'recipeId = ?',
        whereArgs: [recipeId],
      );

      // Map the ingredients data into Ingredient objects
      final ingredients = ingredientsData.map((data) {
        return Ingredient(
          id: data['id'] as int,
          recipeId: data['recipeId'] as int,
          name: data['name'] as String,
          unit: data['unit'] as String?,
          quantity: data['quantity'] as double?,
          note: data['note'] as String?,
        );
      }).toList();

      // Map the stages data into Stage objects
      final stages = stagesData.map((data) {
        return Stage(
          id: data['id'] as int,
          recipeId: data['recipeId'] as int,
          stageNumber: data['stageNumber'] as int?,
          instruction: data['instruction'] as String?,
          duration: data['duration'] as int?,
        );
      }).toList();

      // Map the recipe data into a Recipe object
      final recipe = Recipe(
        id: recipeData.first['id'] as int,
        title: recipeData.first['title'] as String,
        description: recipeData.first['description'] as String?,
        duration: recipeData.first['duration'] as int?,
        difficulty: recipeData.first['difficulty'] as String?,
        createdAt: recipeData.first['createdAt'] as String?,
        updatedAt: recipeData.first['updatedAt'] as String?,
        ingredients: ingredients,
        stages: stages,
      );

      return recipe;
    } catch (e) {
      logger.e('Error fetching recipe: $e');
      throw Exception('Failed to fetch recipe: $e');
    }
  }
}
