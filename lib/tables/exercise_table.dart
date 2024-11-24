import 'package:sqflite/sqflite.dart';

Future<void> createExerciseTable(Database db) async {
  await db.execute('''
    CREATE TABLE Exercise (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      workoutId INTEGER NOT NULL,
      exercise TEXT,
      kg REAL,
      reps INTEGER,
      sets INTEGER,
      FOREIGN KEY (workoutId) REFERENCES Workout (id) ON DELETE CASCADE
    )
  ''');
  print('Exercise table created successfully!');
}

Future<void> migrateExerciseTable(
    Database db, int oldVersion, int newVersion) async {
  if (oldVersion < newVersion) {
    await db.execute('DROP TABLE IF EXISTS Exercise');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Exercise (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutId INTEGER NOT NULL,
        exercise TEXT,
        kg REAL,
        reps INTEGER,
        sets INTEGER,
        FOREIGN KEY (workoutId) REFERENCES Workout (id) ON DELETE CASCADE
      )
    ''');
    print('Exercise table added during migration!');
  }
}
