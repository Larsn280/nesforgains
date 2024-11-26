import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nesforgains/app.dart';
import 'package:nesforgains/database.dart/database.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/service/aws_bucket_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load();

    final sqflite = await setupSQLite();

    final awsBucketService = AwsBucketService();
    await awsBucketService.listBucketContents();

    runApp(App(
      sqflite: sqflite,
    ));
  } catch (e, traceStack) {
    logger.e(e, stackTrace: traceStack);
  }
}
