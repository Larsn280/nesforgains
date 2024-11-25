import 'package:sqflite/sqflite.dart';

Future<void> createDishTable(Database db) async {
  await db.execute('''
    CREATE TABLE Dish (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      calories INTEGER,
      protein INTEGER,
      carbohydrates INTEGER,
      fat INTEGER,
      userId
    )
  ''');
}

Future<void> migrateDishTable(
    Database db, int oldVersion, int newVersion) async {
  if (oldVersion < newVersion) {
    await db.execute('DROP TABLE IF EXISTS Dish');
    await db.execute('''
    CREATE TABLE Dish (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      calories INTEGER,
      protein INTEGER,
      carbohydrates INTEGER,
      fat INTEGER,
      userId
    )
  ''');

    print('Dish table added during migration!');
  }
}
