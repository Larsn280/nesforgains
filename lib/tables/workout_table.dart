import 'package:sqflite/sqflite.dart';

Future<void> createWorkoutTable(Database db) async {
  await db.execute('''
    CREATE TABLE Workout (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      date TEXT,
      userId TEXT,
      markedColor TEXT,
      FOREIGN KEY (userid) REFERENCES AppUser (id) ON DELETE CASCADE
    )
  ''');
}

Future<void> migrateWorkoutTable(
    Database db, int oldVersion, int newVersion) async {
  if (oldVersion < newVersion) {
    await db.execute('DROP TABLE IF EXISTS Workout');
    await db.execute('''
    CREATE TABLE Workout (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      date TEXT,
      userId INTEGER,
      markedColor TEXT
    )
  ''');
  }
}
