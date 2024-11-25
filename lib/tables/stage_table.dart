import 'package:sqflite/sqflite.dart';

Future<void> createStageTable(Database db) async {
  await db.execute('''
    CREATE TABLE Stage (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      recipeId INTEGER NOT NULL,
      stageNumber INTEGER,
      instruction TEXT,
      duration INTEGER,
      FOREIGN KEY (recipeId) REFERENCES Recipe (id) ON DELETE CASCADE
    )
  ''');
}

Future<void> migrateStageTable(
    Database db, int oldVersion, int newVersion) async {
  if (oldVersion < newVersion) {
    await db.execute('DROP TABLE IF EXISTS Stage');
    await db.execute('''
    CREATE TABLE Stage (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      recipeId INTEGER NOT NULL,
      stageNumber INTEGER,
      instruction TEXT,
      duration INTEGER,
      FOREIGN KEY (recipeId) REFERENCES Recipe (id) ON DELETE CASCADE
    )
  ''');

    print('Stage table added during migration!');
  }
}
