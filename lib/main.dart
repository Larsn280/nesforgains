import 'package:flutter/material.dart';
import 'package:nesforgains/app.dart';
import 'package:nesforgains/database.dart/database.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final sqflite = await setupSQLite();

    runApp(App(
      sqflite: sqflite,
    ));
  } catch (e, traceStack) {
    // logger.e(e, stackTrace: traceStack);
  }
}
