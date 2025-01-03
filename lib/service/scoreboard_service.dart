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

      // Step 1: Download data from S3
      var scoreboardJson = await awsbucketService.downloadScoreboard();

      if (scoreboardJson.isEmpty) {
        logger.e("The scoreboard file is empty. Creating default structure.");
        scoreboardJson = json.encode({
          "scoreboard": [],
          "updatedAt": DateTime.now().toIso8601String(),
        });
      }

      final scoreboardData = jsonDecode(scoreboardJson);

      if (scoreboardData is! Map || !scoreboardData.containsKey('scoreboard')) {
        logger.e(
            "The scoreboard data is in an unexpected format. Aborting sync.");
        return;
      }

      final List<Map<String, dynamic>> scoreboardList =
          List<Map<String, dynamic>>.from(scoreboardData['scoreboard']);

      logger.i("Syncing data to database: $scoreboardList");

      // Step 2: Fetch local database records
      final localScores = await fetchLocalUserScores();

      // Step 3: Populate local database if it's empty
      if (localScores.isEmpty) {
        logger.i("Local database is empty. Populating it with S3 data.");
        for (var score in scoreboardList) {
          final userScore = UserScore(
            userid: score['userid'],
            username: score['username'],
            exercise: score['exercise'],
            maxlift: score['maxlift'],
            date: score['date'],
          );
          await insertUserScoreToDatabase(userScore);
          logger.i(
              "Inserted score for ${userScore.username} (${userScore.exercise}).");
        }
        logger.i("Local database populated with S3 data.");
      } else {
        // Step 4: Compare and sync changes
        logger.i("Local database is not empty. Comparing data for updates.");
        await compareScoreboardWithDatabase(scoreboardList);
      }
    } catch (e) {
      logger.e("Error syncing data from S3: $e");
      rethrow;
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
    const query = '''
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
      final localScores = await fetchLocalUserScores();

      final localKeys = localScores.map((localScore) {
        return "${localScore['userid']}_${localScore['exercise']}";
      }).toSet();

      final scoreboardKeys = scoreboard.map((scoreEntry) {
        return "${scoreEntry['userid']}_${scoreEntry['exercise']}";
      }).toSet();

      bool isUpdated = false;

      final batch = sqflite.batch();

      for (var localScore in localScores) {
        final localKey = "${localScore['userid']}_${localScore['exercise']}";
        if (!scoreboardKeys.contains(localKey)) {
          logger.i(
              "Adding missing local score for ${localScore['username']} (${localScore['exercise']}) to scoreboard.");

          scoreboard.add({
            'userid': localScore['userid'],
            'username': localScore['username'],
            'exercise': localScore['exercise'],
            'maxlift': localScore['maxlift'],
            'date': localScore['date'],
          });

          isUpdated = true;
        }
      }

      for (var s3Score in scoreboard) {
        final s3Key = "${s3Score['userid']}_${s3Score['exercise']}";
        if (!localKeys.contains(s3Key)) {
          logger.i(
              "Adding missing S3 score for ${s3Score['username']} (${s3Score['exercise']}) to local database.");

          batch.insert(
              'UserScore',
              {
                'userid': s3Score['userid'],
                'username': s3Score['username'],
                'exercise': s3Score['exercise'],
                'maxlift': s3Score['maxlift'],
                'date': s3Score['date'],
              },
              conflictAlgorithm: ConflictAlgorithm.ignore);
        } else {
          final existingLocalScore = localScores.firstWhere(
            (localScore) =>
                localScore['userid'] == s3Score['userid'] &&
                localScore['exercise'] == s3Score['exercise'],
            orElse: () =>
                <String, dynamic>{}, // Return an empty map instead of null
          );

          if (existingLocalScore.isNotEmpty &&
              existingLocalScore['maxlift'] != s3Score['maxlift']) {
            logger.i(
                "Updating local database for ${existingLocalScore['username']} (${existingLocalScore['exercise']}) with new maxlift: ${s3Score['maxlift']}.");

            // Update the local database
            batch.update(
              'UserScore',
              {
                'maxlift': s3Score['maxlift'],
                'date': s3Score['date'],
              },
              where: 'userid = ? AND exercise = ?',
              whereArgs: [s3Score['userid'], s3Score['exercise']],
            );

            // Update the scoreboard entry
            s3Score['maxlift'] = existingLocalScore['maxlift'];
            s3Score['date'] = existingLocalScore['date'];

            isUpdated = true;
          }
        }
      }

      await batch.commit();

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

  Future<void> updateUserScoreInDatabase(UserScore userScore) async {
    try {
      // Update the user score where userid and exercise match
      await sqflite.update(
        'UserScore', // Table name
        {
          'date': userScore.date,
          'maxlift': userScore.maxlift,
        },
        where: 'userid = ? AND exercise = ?',
        whereArgs: [userScore.userid, userScore.exercise],
      );

      logger.i(
          "Updated score for ${userScore.username} in exercise ${userScore.exercise} to maxlift ${userScore.maxlift}.");
    } catch (e) {
      logger.e("Error updating score in UserScore table: $e");
      rethrow;
    }
  }
}
