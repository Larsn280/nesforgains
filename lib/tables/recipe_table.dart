import 'package:sqflite/sqflite.dart';

Future<void> createRecipeTable(Database db) async {
  await db.execute('''
    CREATE TABLE Recipe (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      duration INTEGER,
      difficulty TEXT,
      createdAt TEXT,
      updatedAT TEXT
    )
  ''');
}

Future<void> migrateRecipeTable(
    Database db, int oldVersion, int newVersion) async {
  if (oldVersion < newVersion) {
    await db.execute('DROP TABLE IF EXISTS Recipe');
    await db.execute('''
    CREATE TABLE Recipe (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      duration INTEGER,
      difficulty TEXT,
      createdAt TEXT,
      updatedAT TEXT
    )
  ''');

    print('Recipe table added during migration!');
  }
}
