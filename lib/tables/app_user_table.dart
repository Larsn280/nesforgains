import 'package:sqflite/sqflite.dart';

Future<void> createAppUserTable(Database db) async {
  await db.execute('''
    CREATE TABLE AppUser (
      id TEXT PRIMARY KEY,
      username TEXT,
      email TEXT,
      password TEXT,
      age INTEGER
      
    )
  ''');
}

Future<void> migrateAppUserTable(
    Database db, int oldVersion, int newVersion) async {
  if (oldVersion < newVersion) {
    await db.execute('DROP TABLE IF EXISTS AppUser');
    await db.execute('''
    CREATE TABLE AppUser (
          id TEXT PRIMARY KEY,
          username TEXT,
          email TEXT,
          password TEXT,
          age INTEGER
        )
      ''');
  }
}
