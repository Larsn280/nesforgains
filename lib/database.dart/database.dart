import 'package:nesforgains/database.dart/database_schema.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> setupSQLite() async {
  // Get the application document directory
  final dir = await getApplicationDocumentsDirectory();
  final path = join(dir.path, 'nesforgains.db');

  // await deleteDatabase(path);

  // Open or create the SQLite database
  final database =
      await openDatabase(path, version: 10, // Increment the version number
          onCreate: (db, version) async {
    await onCreate(db, version);
  }, onUpgrade: (db, oldVersion, newVersion) async {
    await onUpgrade(db, oldVersion, newVersion);
  });

  // final tables = await database
  //     .rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
  // print('Existing tables: $tables');

  return database;
}
