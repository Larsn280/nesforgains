import 'package:nesforgains/tables/app_user_table.dart';
import 'package:nesforgains/tables/exercise_table.dart';
import 'package:nesforgains/tables/workout_table.dart';
import 'package:sqflite/sqflite.dart';

Future<void> onCreate(Database db, int version) async {
  // Call create methods for each table
  await createAppUserTable(db);
  await createWorkoutTable(db);
  await createExerciseTable(db);
  // Add other table creation calls here
  // await createRecipeTable(db);
}

Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
  // await migrateAppUserTable(db, oldVersion, newVersion);
  // await migrateWorkoutTable(db, oldVersion, newVersion);
  await migrateExerciseTable(db, oldVersion, newVersion);
}
