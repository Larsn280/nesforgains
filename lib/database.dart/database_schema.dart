import 'package:nesforgains/tables/app_user_table.dart';
import 'package:nesforgains/tables/dish_table.dart';
import 'package:nesforgains/tables/exercise_table.dart';
import 'package:nesforgains/tables/ingredient_table.dart';
import 'package:nesforgains/tables/nutrition_table.dart';
import 'package:nesforgains/tables/recipe_table.dart';
import 'package:nesforgains/tables/stage_table.dart';
import 'package:nesforgains/tables/user_score_table.dart';
import 'package:nesforgains/tables/workout_table.dart';
import 'package:sqflite/sqflite.dart';

Future<void> onCreate(Database db, int version) async {
  // Call create methods for each table
  await createAppUserTable(db);
  await createWorkoutTable(db);
  await createExerciseTable(db);
  await createRecipeTable(db);
  await createIngredientTable(db);
  await createStageTable(db);
  await createDishTable(db);
  await createNutritionTable(db);
  await createUserScoreTable(db);
}

Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
  // await migrateDishTable(db, oldVersion, newVersion);
  // await migrateNutritionTable(db, oldVersion, newVersion);
  // await migrateIngredientTable(db, oldVersion, newVersion);
  // await migrateStageTable(db, oldVersion, newVersion);
  // await migrateRecipeTable(db, oldVersion, newVersion);
  // await migrateExerciseTable(db, oldVersion, newVersion);
  await migrateUserScoreTable(db, oldVersion, newVersion);
}
