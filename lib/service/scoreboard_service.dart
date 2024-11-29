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
        // Default empty scoreboard structure
        scoreboardJson = json.encode({
          "scoreboard": [],
          "updatedAt": DateTime.now().toIso8601String(),
        });
      }

      // Parse the downloaded JSON string into a Map or List (depending on the structure)
      final scoreboardData = jsonDecode(scoreboardJson);

      // Check if the JSON data has the expected structure
      if (scoreboardData is! Map || !scoreboardData.containsKey('scoreboard')) {
        logger.e(
            "The scoreboard data is in an unexpected format. Aborting sync.");
        return;
      }

      // Extract the 'scoreboard' list from the parsed data
      final List<Map<String, dynamic>> scoreboardList =
          List<Map<String, dynamic>>.from(scoreboardData['scoreboard']);

      // Log the scoreboard data for debugging
      logger.i("Syncing data to database: $scoreboardList");

      // Check if the local database is empty
      final localScores = await fetchLocalUserScores();

      if (localScores.isEmpty) {
        logger.i("Local database is empty. Populating it with S3 data.");

        // Populate the local database with the scoreboard data from S3
        for (var score in scoreboardList) {
          await insertUserScoreToDatabase(UserScore(
            userid: score['userid'],
            username: score['username'],
            exercise: score['exercise'],
            maxlift: score['maxlift'],
            date: score['date'],
          ));
        }

        logger.i("Local database populated with data from S3.");
      } else {
        logger.i("Local database is not empty. Comparing data for updates.");
        // Compare the data and sync changes
        await compareScoreboardWithDatabase(scoreboardList);
      }
    } catch (e) {
      logger.e("Error syncing data from S3: $e");
      rethrow; // Rethrow the error after logging it
    }
  }

  Future<List<UserscoreViewmodel>>
      getAllExerciseScoresInDescendingOrder() async {
    try {
      // Define the SQL query with a WHERE clause to filter for Benchpress
      const query = '''
    SELECT username, date, exercise, MAX(maxlift) as maxlift
    FROM UserScore
    -- WHERE exercise = 'Squats'  -- Filter for Benchpress
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
          date: row['date'] as String?,
          exercise: row['exercise'] as String?,
          maxlift: row['maxlift'] as int?,
        );
      }).toList();
    } catch (e) {
      logger.e('Error fetching Powerlifting scores: $e');
      throw Exception('Failed to fetch Powerlifting scores: $e');
    }
  }

  Future<List<UserscoreViewmodel>>
      getBenchpressScoresInDescendingOrder() async {
    try {
      // Define the SQL query with a WHERE clause to filter for Benchpress
      const query = '''
    SELECT username, date, exercise, MAX(maxlift) as maxlift
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
          date: row['date'] as String?,
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
    const deleteQuery = '''
    DELETE FROM UserScore
    WHERE userid IN (
      SELECT w.userId
      FROM Workout w
      INNER JOIN Exercise e ON e.workoutId = w.id
      WHERE e.name IN ('Benchpress', 'Squats', 'Deadlift')
    ) AND exercise IN ('Benchpress', 'Squats', 'Deadlift');
  ''';

    const insertQuery = '''
    INSERT INTO UserScore (userid, date, username, exercise, maxlift)
    SELECT 
        w.userId AS userid,
        w.date AS date,
        ? AS username,  -- Use a parameter placeholder for the username
        e.name AS exercise,
        CAST(MAX(e.kg) AS INTEGER) AS maxlift
    FROM Exercise e
    INNER JOIN Workout w ON e.workoutId = w.id
    WHERE e.name IN ('Benchpress', 'Squats', 'Deadlift')  -- Filter for specified exercises
    GROUP BY w.userId, e.name;
  ''';

    try {
      // Step 1: Delete old scores for specified exercises
      await sqflite.rawDelete(deleteQuery);
      print('Old scores deleted successfully.');

      // Step 2: Insert the new max lifts for the specified exercises (whether higher or lower)
      await sqflite.rawInsert(insertQuery, [username]);
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

  Future<void> compareScoreboardWithDatabase(
      List<Map<String, dynamic>> scoreboard) async {
    try {
      // Fetch data from UserScore table (local database)
      final localScores = await fetchLocalUserScores();

      // Create a set of unique keys from the scoreboard for fast lookup
      final scoreboardKeys = scoreboard.map((scoreEntry) {
        return "${scoreEntry['userid']}_${scoreEntry['exercise']}";
      }).toSet();

      // Track whether we need to update the scoreboard
      bool isUpdated = false;

      for (var localScore in localScores) {
        final localKey = "${localScore['userid']}_${localScore['exercise']}";

        // Check if this local score is missing in the scoreboard
        if (!scoreboardKeys.contains(localKey)) {
          logger.i(
              "Adding missing local score for ${localScore['username']} (${localScore['exercise']}) to scoreboard.");

          // Add the local score to the scoreboard
          scoreboard.add({
            'userid': localScore['userid'],
            'username': localScore['username'],
            'exercise': localScore['exercise'],
            'maxlift': localScore['maxlift'],
            'date': localScore['date'], // Ensure the date format matches
          });

          // Mark that the scoreboard was updated
          isUpdated = true;
        } else {
          // If the score exists in the scoreboard, check if maxlift is different
          final existingScore = scoreboard.firstWhere(
              (score) =>
                  score['userid'] == localScore['userid'] &&
                  score['exercise'] == localScore['exercise'],
              orElse: () => {} // Return an empty map instead of null
              );

          if (existingScore.isNotEmpty) {
            // Update if maxlift is different
            if (localScore['maxlift'] != existingScore['maxlift']) {
              logger.i(
                  "Updating maxlift for ${localScore['username']} (${localScore['exercise']}) in scoreboard.");

              // Update the existing entry with the new maxlift and date
              existingScore['maxlift'] = localScore['maxlift'];
              existingScore['date'] = localScore['date']; // Update the date
              isUpdated = true;
            }
          }
        }
      }

      // If the scoreboard was updated, wrap it with `updatedAt` and upload to S3
      if (isUpdated) {
        final updatedScoreboard = {
          'scoreboard': scoreboard,
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final updatedScoreboardJson = jsonEncode(updatedScoreboard);
        final awsbucketService = AwsBucketService();

        final uploadResult =
            await awsbucketService.uploadScoreboard(updatedScoreboardJson);
        if (uploadResult) {
          logger.i("Scoreboard successfully updated and uploaded to S3.");
        } else {
          logger.e("Failed to upload updated scoreboard to S3.");
        }
      } else {
        logger.i("No updates were needed for the scoreboard.");
      }
    } catch (e) {
      logger.e("Error comparing and updating scoreboard: $e");
      rethrow;
    }
  }

  Future<void> insertUserScoreToDatabase(UserScore userScore) async {
    try {
      // Insert the user score into the UserScore table
      await sqflite.insert(
        'UserScore', // Table name
        {
          'userid': userScore.userid, // Foreign key to AppUser table
          'date': userScore.date,
          'username': userScore.username,
          'exercise': userScore.exercise,
          'maxlift': userScore.maxlift,
        },
        conflictAlgorithm:
            ConflictAlgorithm.ignore, // Ignore if a conflict occurs
      );

      logger.i(
          "Inserted score for ${userScore.username} in exercise ${userScore.exercise} date ${userScore.date} into the UserScore table.");
    } catch (e) {
      logger.e("Error inserting score into UserScore table: $e");
      rethrow; // Re-throw the error for higher-level handling
    }
  }
}
