import 'package:sqflite/sqflite.dart';

Future<void> createIngredientTable(Database db) async {
  await db.execute('''
    CREATE TABLE Ingredient (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      recipeId INTEGER NOT NULL,
      name TEXT,
      unit TEXT,
      quantity REAL,
      note TEXT,
      FOREIGN KEY (recipeId) REFERENCES Recipe (id) ON DELETE CASCADE
    )
  ''');
}

Future<void> migrateIngredientTable(
    Database db, int oldVersion, int newVersion) async {
  if (oldVersion < newVersion) {
    await db.execute('DROP TABLE IF EXISTS Ingredient');
    await db.execute('''
    CREATE TABLE Ingredient (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      recipeId INTEGER NOT NULL,
      name TEXT,
      unit TEXT,
      quantity REAL,
      note TEXT,
      FOREIGN KEY (recipeId) REFERENCES Recipe (id) ON DELETE CASCADE
    )
  ''');

    print('Ingredient table added during migration!');
  }
}
