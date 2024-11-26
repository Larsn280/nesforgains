import 'package:nesforgains/logger.dart';
import 'package:nesforgains/service/aws_bucket_service.dart';
import 'package:nesforgains/viewModels/userscore_viewmodel.dart';
import 'package:sqflite/sqflite.dart';

class ScoreboardService {
  final Database sqflite;

  ScoreboardService(this.sqflite);

  Future<void> syncS3ToDatabase() async {
    try {
      final awsBucketService = AwsBucketService();
      // Step 1: Download the JSON file
      final scoreboardData = await awsBucketService.downloadScoreboard();

      if (scoreboardData == null) {
        logger.e("No data found in the S3 JSON file.");
        return;
      }

      // Step 2: Parse and extract relevant fields
      final name = scoreboardData['name'] as String?;
      final maxBench = scoreboardData['max-bench'] as int?;

      if (name == null || maxBench == null) {
        logger.e("Invalid data structure in the S3 JSON file.");
        return;
      }

      // Step 3: Define the exercise (you can customize this)
      const exercise = "Benchpress";

      // Step 4: Insert into the UserScore table
      final query = '''
      INSERT INTO UserScore (userid, username, exercise, maxlift)
      VALUES (?, ?, ?, ?)
    ''';

      // Assuming `sqflite` is your database instance
      await sqflite.rawInsert(query, [null, name, exercise, maxBench]);

      logger.i("Data successfully synced from S3 to the database!");
    } catch (e) {
      logger.e("Error syncing data from S3: $e");
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
}
