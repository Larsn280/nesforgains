import 'package:sqflite/sqflite.dart';

Future<void> createNutritionTable(Database db) async {
  await db.execute('''
    CREATE TABLE Nutrition (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      calories INTEGER,
      protein INTEGER,
      carbohydrates INTEGER,
      fat INTEGER,
      userId
    )
  ''');
}

Future<void> migrateNutritionTable(
    Database db, int oldVersion, int newVersion) async {
  if (oldVersion < newVersion) {
    await db.execute('DROP TABLE IF EXISTS Nutrition');
    await db.execute('''
    CREATE TABLE Nutrition (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      calories INTEGER,
      protein INTEGER,
      carbohydrates INTEGER,
      fat INTEGER,
      userId
    )
  ''');

    print('Nutrition table added during migration!');
  }
}
