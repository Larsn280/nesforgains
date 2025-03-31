import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nesforgains/app.dart';
import 'package:nesforgains/database.dart/database.dart';
import 'package:nesforgains/logger.dart';
// import 'package:nesforgains/service/scoreboard_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load();

    final sqflite = await setupSQLite();

    // final scoreboardService = ScoreboardService(sqflite);
    // await scoreboardService.syncS3ToDatabase();

    runApp(App(
      sqflite: sqflite,
    ));
  } catch (e, traceStack) {
    logger.e(e, stackTrace: traceStack);
  }
}
