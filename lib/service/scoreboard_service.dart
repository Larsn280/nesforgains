import 'dart:convert';

import 'package:nesforgains/logger.dart';
import 'package:nesforgains/service/aws_bucket_service.dart';
import 'package:nesforgains/viewModels/userscore_viewmodel.dart';
import 'package:sqflite/sqflite.dart';

class ScoreboardService {
  final Database sqflite;

  ScoreboardService(this.sqflite);

  Future<void> syncS3ToDatabase() async {
    try {
      final awsbucketService = AwsBucketService();
      // Download the scoreboard data from S3 as a String
      var scoreboardJson = await awsbucketService.downloadScoreboard();

      if (scoreboardJson.isEmpty) {
        // If the file is empty, create an empty structure or default data
        logger.e("The scoreboard file is empty. Creating default structure.");
        // You might want to insert default values into the database here.
        scoreboardJson = json.encode({
          "scoreboard": [], // Initial empty scoreboard array
          "updatedAt":
              DateTime.now().toIso8601String(), // Track last update timestamp
        });
      }

      // Parse the downloaded JSON string into a Map or List (depending on the structure)
      final scoreboardData =
          jsonDecode(scoreboardJson); // Parse the JSON string

      // Check if the JSON data has the expected structure
      if (scoreboardData is! Map || !scoreboardData.containsKey('scoreboard')) {
        logger.e(
            "The scoreboard data is in an unexpected format. Creating default structure.");
        // Insert default data into the database here, if needed.
        return;
      }

      // Now you can work with the parsed data
      logger.i("Syncing data to database: $scoreboardData");

      // Your code for syncing the data to the local database goes here
      // For example:
      // await database.insert('scoreboard', scoreboardData);
    } catch (e) {
      logger.e("Error syncing data from S3: $e");
      rethrow; // Rethrow the error after logging it
    }
  }

  Future<List<UserscoreViewmodel>>
      getBenchpressScoresInDescendingOrder() async {
    try {
      // Define the SQL query with a WHERE clause to filter for Benchpress
      const query = '''
    SELECT username, exercise, MAX(maxlift) as maxlift
    FROM UserScore
    WHERE exercise = 'Benchpress'  -- Filter for Benchpress
    GROUP BY username, exercise
    ORDER BY maxlift DESC
    ''';

      // Execute the query
      final results = await sqflite.rawQuery(query);

      // If the table is empty, return an empty list
      if (results.isEmpty) {
        return [];
      }

      // Convert the results into a list of UserscoreViewmodel
      return results.map((row) {
        return UserscoreViewmodel(
          name: row['username'] as String?,
          exercise: row['exercise'] as String?,
          maxlift: row['maxlift'] as int?,
        );
      }).toList();
    } catch (e) {
      logger.e('Error fetching Benchpress scores: $e');
      throw Exception('Failed to fetch Benchpress scores: $e');
    }
  }

  Future<void> updateUserScoresWithMaxLifts(String username) async {
    const query = '''
  INSERT INTO UserScore (userid, username, exercise, maxlift)
  SELECT 
      w.userId AS userid,
      ? AS username,  -- Use a parameter placeholder for the username
      e.name AS exercise,
      CAST(MAX(e.kg) AS INTEGER) AS maxlift
  FROM Exercise e
  INNER JOIN Workout w ON e.workoutId = w.id
  LEFT JOIN UserScore us ON us.userid = w.userId AND us.exercise = e.name
  GROUP BY w.userId, e.name
  HAVING (us.maxlift IS NULL OR us.maxlift != CAST(MAX(e.kg) AS INTEGER));
  ''';

    try {
      // Pass the username value as a parameter
      await sqflite.rawQuery(query, [username]);
      print('User scores updated successfully for $username.');
    } catch (e) {
      logger.e('Error updating user scores: $e');
      throw Exception('Failed to update user scores: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchLocalUserScores() async {
    final query = '''
    SELECT id, userid, date, username, exercise, maxlift FROM UserScore
  ''';

    try {
      // Assuming `sqflite` is your database instance
      final scores = await sqflite.rawQuery(query);
      return scores; // Returns a list of maps containing UserScore data
    } catch (e) {
      logger.e("Error fetching local UserScore data: $e");
      return [];
    }
  }
}
