import 'dart:convert';

import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/user_score.dart';
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

      // Extract the 'scoreboard' list from the parsed data
      final List<Map<String, dynamic>> scoreboardList =
          List<Map<String, dynamic>>.from(scoreboardData['scoreboard']);

      // Now you can work with the parsed data
      logger.i("Syncing data to database: $scoreboardList");

      if (scoreboardList.isEmpty) {
        logger.e("The scoreboard is empty. No data to sync.");
        // Fetch data from the local database (UserScore table)
        final localScores = await fetchLocalUserScores();

        if (localScores.isEmpty) {
          logger.e("Local database is empty. No data to sync.");
          return;
        } else {
          var updatedScoreboardJson = json.encode({
            "scoreboard": localScores.map((score) {
              return {
                "userid": score['userid'],
                "username": score['username'],
                "exercise": score['exercise'],
                "maxlift": score['maxlift'],
                "date": score['date'],
              };
            }).toList(),
            "updatedAt": DateTime.now().toIso8601String(),
          });

          // Upload the updated scoreboard to the S3 bucket
          await awsbucketService.uploadScoreboard(updatedScoreboardJson);
          logger.i(
              "Updated the scoreboard file in S3 with local UserScore data.");
          return; // Exit here since we've already updated the file
        }
        // You can insert default values into the database or log a message if needed
      } else {
        await compareScoreboardWithDatabase(scoreboardList);
      }

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

  // Function to check if the scoreboard matches the UserScore table
  Future<void> compareScoreboardWithDatabase(
      List<Map<String, dynamic>> scoreboard) async {
    try {
      // Fetch data from UserScore table (local database)
      final localScores = await fetchLocalUserScores();

      // Loop through each entry in the scoreboard and check if it matches any UserScore
      for (var scoreEntry in scoreboard) {
        // Create a UserScore object from the scoreboard data
        final userScore = UserScore(
          userid: scoreEntry['userid'], // Ensure the key matches your structure
          username: scoreEntry['username'],
          exercise: scoreEntry['exercise'],
          maxlift: scoreEntry['maxlift'],
          date: scoreEntry['date'],
        );

        // Check if this score exists in the local UserScore table
        bool isFound = localScores.any((localScore) {
          // Compare excluding the `id` field
          return localScore['userid'] == userScore.userid &&
              localScore['username'] == userScore.username &&
              localScore['exercise'] == userScore.exercise &&
              localScore['maxlift'] ==
                  userScore
                      .maxlift; // Optional: include maxlift if you want to compare it
        });

        if (isFound) {
          logger.i(
              "Found matching score for ${userScore.username} in exercise ${userScore.exercise}");
        } else {
          logger.e(
              "No match found for ${userScore.username} in exercise ${userScore.exercise}, adding to database.");
          await insertUserScoreToDatabase(
              userScore); // Insert the missing score into the database
        }
      }
    } catch (e) {
      logger.e("Error comparing scoreboard with database: $e");
      rethrow;
    }
  }

// Simulate inserting missing scores to the database (adjust for actual DB logic)
  Future<void> insertUserScoreToDatabase(UserScore userScore) async {
    // Insert the missing user score into your database (adjust for your DB logic)
    logger.i(
        "Inserting missing score for ${userScore.username} in exercise ${userScore.exercise} into database.");
    // For example: await database.insert('user_scores', userScore.toMap());
  }
}
