import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> setupSQLite() async {
  // Get the application document directory
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, 'nesforgains.db'); // Define database file path

  // Open or create the SQLite database
  final database = await openDatabase(
    path,
    version: 2, // Increment the version number
    onCreate: (db, version) async {
      // Define schema creation for all tables
      await db.execute('''
        CREATE TABLE AppUser (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT,
          email TEXT,
          password TEXT,
          age INTEGER
        )
      ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      // Handle migrations
      if (oldVersion < 2) {
        await db
            .execute('ALTER TABLE AppUser ADD COLUMN age INTEGER DEFAULT 0');
      }
    },
  );

  return database;
}
