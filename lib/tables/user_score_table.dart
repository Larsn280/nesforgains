import 'package:sqflite/sqflite.dart';

Future<void> createUserScoreTable(Database db) async {
  await db.execute('''
    CREATE TABLE UserScore (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userid TEXT,
      date TEXT,
      username TEXT,
      exercise TEXT,
      maxlift INTEGER,
      FOREIGN KEY (userid) REFERENCES AppUser (id) ON DELETE CASCADE
      )
  ''');
}

Future<void> migrateUserScoreTable(
    Database db, int oldVersion, int newVersion) async {
  if (oldVersion < newVersion) {
    await db.execute('''
    ALTER TABLE UserScore ADD COLUMN date TEXT''');
    print('UserScore table was updated during migration!');
  }
}
