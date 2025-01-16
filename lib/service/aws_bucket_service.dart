import 'dart:convert';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/viewModels/userscore_viewmodel.dart';

class AwsBucketService {
  Future<List<UserscoreViewmodel>> fetchUserscoreDirectlyFromS3() async {
    try {
      const bucketName = 'scoreboardbucketnesforgains-flutter';
      final region = dotenv.env['AWS_REGION'] ?? 'eu-north-1';
      final accessKeyId = dotenv.env['AWS_ACCESS_KEY_ID']!;
      final secretAccessKey = dotenv.env['AWS_SECRET_ACCESS_KEY']!;

      final credentials = AWSCredentials(accessKeyId, secretAccessKey);
      final awsSigner = AWSSigV4Signer(
        credentialsProvider: AWSCredentialsProvider(credentials),
      );

      final endpoint = Uri.https(
        '$bucketName.s3.$region.amazonaws.com',
        '/Benchpress.json',
      );

      final scope = AWSCredentialScope(region: region, service: AWSService.s3);

      final request = AWSHttpRequest(
        method: AWSHttpMethod.get,
        uri: endpoint,
      );

      final signedRequest = await awsSigner.sign(
        request,
        credentialScope: scope,
      );

      // Hämta data från S3
      final response = await http.get(
        signedRequest.uri,
        headers: signedRequest.headers,
      );

      if (response.statusCode == 200) {
        final jsonString = utf8.decode(response.bodyBytes);
        logger.i("Successfully fetched JSON from S3.");

        // Parsar JSON-strängen till en lista med UserscoreViewmodel
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);

        if (!jsonData.containsKey('scoreboard') ||
            jsonData['scoreboard'] is! List) {
          logger.e(
              "Invalid JSON structure: 'scoreboard' key is missing or not a list.");
          return [];
        }

        final List<dynamic> scoreboard = jsonData['scoreboard'];
        final List<UserscoreViewmodel> userScores = scoreboard.map((score) {
          return UserscoreViewmodel(
            name: score['username'] as String?,
            date: score['date'] as String?,
            exercise: score['exercise'] as String?,
            maxlift: _parseMaxlift(score['maxlift']),
          );
        }).toList();

        // Sort the list by maxlift (descending) and by date (ascending) in case of ties
        userScores.sort((a, b) {
          // Compare maxlift in descending order, considering null values
          final maxliftA =
              a.maxlift ?? double.negativeInfinity; // Handle null maxlift
          final maxliftB =
              b.maxlift ?? double.negativeInfinity; // Handle null maxlift

          int maxliftComparison = maxliftB.compareTo(maxliftA);
          if (maxliftComparison != 0) {
            return maxliftComparison;
          }

          // Compare date in ascending order, considering null values
          final dateA = a.date ?? ''; // Handle null date (empty string if null)
          final dateB = b.date ?? ''; // Handle null date (empty string if null)

          return dateA.compareTo(dateB);
        });

        return userScores;
      } else {
        logger.e("Failed to fetch JSON from S3: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      logger.e("Error fetching JSON from S3: $e");
      return [];
    }
  }

// Helper function to handle type conversion for maxlift
  int? _parseMaxlift(dynamic maxlift) {
    if (maxlift is double) {
      return maxlift.toInt(); // Convert double to int
    } else if (maxlift is int) {
      return maxlift; // Already an int, return as is
    }
    return null; // Return null if it's neither double nor int
  }

  Future<void> syncBenchpressToS3(
      String userId, String username, int? maxlift) async {
    try {
      // Step 1: Fetch the current scoreboard from S3
      final scoreboardJson = await downloadScoreboard();
      if (scoreboardJson.isEmpty) {
        logger.e("Scoreboard file is empty or not found.");
        return;
      }

      // Step 2: Parse the fetched scoreboard JSON
      final Map<String, dynamic> scoreboardData = jsonDecode(scoreboardJson);
      final List<dynamic> scoreboardList = scoreboardData['scoreboard'];

      // Step 3: Check if your user ID is already in the scoreboard for "Benchpress"
      bool userFound = false;
      for (var entry in scoreboardList) {
        if (entry['userid'] == userId && entry['exercise'] == 'Benchpress') {
          userFound = true;

          // Step 4: If user is found, compare the local maxlift with the one in the JSON file
          final currentMaxlift = entry['maxlift'] as int;

          // If local maxlift is different, update the JSON with the local maxlift
          if (maxlift != null && maxlift != currentMaxlift) {
            entry['maxlift'] = maxlift;
            logger.i("Updated maxlift to the local value: $maxlift");
          }
          break;
        }
      }

      // Step 5: If the user is not found and there is a valid maxlift, add a new entry
      if (!userFound && maxlift != null && maxlift > 0) {
        final newScore = {
          'userid': userId,
          'username': username, // Replace with actual username if available
          'exercise': 'Benchpress',
          'maxlift': maxlift,
          'date': DateTime.now()
              .toIso8601String()
              .split('T')[0], // Only date, no time
        };

        scoreboardList.add(newScore);
        logger.i(
            "Added new Benchpress score with maxlift $maxlift to the scoreboard.");
      }

      // Step 6: If no valid maxlift locally, remove the user from the scoreboard
      if (maxlift == null || maxlift <= 0) {
        scoreboardList.removeWhere((entry) =>
            entry['userid'] == userId && entry['exercise'] == 'Benchpress');
        logger.i(
            "Removed user $userId from the scoreboard due to missing or invalid maxlift.");
      }

      // Step 7: Upload the updated scoreboard back to S3
      final updatedScoreboard = {
        'scoreboard': scoreboardList,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final updatedScoreboardJson = jsonEncode(updatedScoreboard);

      final uploadResult = await uploadScoreboard(updatedScoreboardJson);

      if (uploadResult) {
        logger.i("Scoreboard successfully updated and uploaded to S3.");
      } else {
        logger.e("Failed to upload updated scoreboard to S3.");
      }
    } catch (e) {
      logger.e("Error syncing Benchpress to S3: $e");
      rethrow;
    }
  }

  Future<void> listBucketContents() async {
    const bucketName = 'scoreboardbucketnesforgains-flutter';
    final region =
        dotenv.env['AWS_REGION'] ?? 'eu-north-1'; // Get region from .env
    final accessKeyId = dotenv.env['AWS_ACCESS_KEY_ID']!;
    final secretAccessKey = dotenv.env['AWS_SECRET_ACCESS_KEY']!;

    // Create AWS credentials from the environment
    final credentials = AWSCredentials(accessKeyId, secretAccessKey);
    final awsSigner = AWSSigV4Signer(
        credentialsProvider: AWSCredentialsProvider(credentials));

    // The endpoint for listing bucket contents
    final endpoint = Uri.https(
        '$bucketName.s3.$region.amazonaws.com', '/', {'list-type': '2'});

    // Create the signing scope
    final scope = AWSCredentialScope(region: region, service: AWSService.s3);

    // Sign the request
    final signedRequest = await awsSigner.sign(
      AWSHttpRequest(method: AWSHttpMethod.get, uri: endpoint),
      credentialScope: scope,
    );

    // Perform the HTTP request
    final response = await http.get(
      signedRequest.uri,
      headers: signedRequest.headers,
    );

    // Handle the response
    if (response.statusCode == 200) {
      logger.i('Bucket Contents: ${response.body}');
    } else {
      logger.e('Failed to fetch bucket contents: ${response.statusCode}');
    }
  }

  Future<String> downloadScoreboard() async {
    const bucketName = 'scoreboardbucketnesforgains-flutter';
    final region = dotenv.env['AWS_REGION'] ?? 'eu-north-1';
    final accessKeyId = dotenv.env['AWS_ACCESS_KEY_ID']!;
    final secretAccessKey = dotenv.env['AWS_SECRET_ACCESS_KEY']!;

    final credentials = AWSCredentials(accessKeyId, secretAccessKey);
    final awsSigner = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(credentials),
    );

    final endpoint = Uri.https(
      '$bucketName.s3.$region.amazonaws.com',
      '/Benchpress.json',
    );

    final scope = AWSCredentialScope(region: region, service: AWSService.s3);

    final request = AWSHttpRequest(
      method: AWSHttpMethod.get,
      uri: endpoint,
    );

    final signedRequest = await awsSigner.sign(
      request,
      credentialScope: scope,
    );

    try {
      // Make the actual request to S3
      final response = await http.get(
        signedRequest.uri,
        headers: signedRequest.headers,
      );

      if (response.statusCode == 200) {
        // File found, returning its content
        final responseBody = utf8.decode(response.bodyBytes);
        logger.i("File downloaded: $responseBody");

        // If the file is empty or doesn't contain the expected structure, handle it.
        if (responseBody.isEmpty || !responseBody.contains('scoreboard')) {
          logger.e("File is empty or doesn't contain the expected structure.");
          await createScoreboardFile(); // Recreate the file with default structure
          return ''; // Returning empty string as a new file will be created
        }

        return responseBody;
      } else if (response.statusCode == 404) {
        // File not found, create it
        logger.e("Benchpress.json not found. Creating new file...");
        await createScoreboardFile();
        return ''; // Returning empty string as a new file will be created
      } else {
        // Handle other errors
        logger.e("Failed to download file: ${response.statusCode}");
        throw Exception("Failed to download file from S3.");
      }
    } catch (e) {
      logger.e("Error downloading file: $e");
      rethrow;
    }
  }

  Future<void> createScoreboardFile() async {
    const bucketName = 'scoreboardbucketnesforgains-flutter';
    final region = dotenv.env['AWS_REGION'] ?? 'eu-north-1';
    final accessKeyId = dotenv.env['AWS_ACCESS_KEY_ID']!;
    final secretAccessKey = dotenv.env['AWS_SECRET_ACCESS_KEY']!;

    final credentials = AWSCredentials(accessKeyId, secretAccessKey);
    final awsSigner = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(credentials),
    );

    final endpoint = Uri.https(
      '$bucketName.s3.$region.amazonaws.com',
      '/Benchpress.json',
    );

    final scope = AWSCredentialScope(region: region, service: AWSService.s3);

    // JSON data to initialize the file (default structure, you can customize it)
    final jsonData = json.encode({
      "scoreboard": [], // Initial empty scoreboard array
      "updatedAt":
          DateTime.now().toIso8601String(), // Track last update timestamp
    });

    // Convert the JSON string to bytes (List<int>)
    final bodyBytes = utf8.encode(jsonData); // Convert to List<int> (bytes)

    final request = AWSHttpRequest(
      method: AWSHttpMethod.put,
      uri: endpoint,
      body: bodyBytes, // Pass the body as List<int> (bytes)
    );

    final signedRequest = await awsSigner.sign(
      request,
      credentialScope: scope,
    );

    try {
      // Upload the file to S3
      final response = await http.put(
        signedRequest.uri,
        headers: signedRequest.headers,
        body: bodyBytes, // Send the body as bytes (List<int>)
      );

      if (response.statusCode == 200) {
        logger.i("Benchpress.json successfully created in S3.");
      } else {
        logger.e("Failed to create Benchpress.json: ${response.statusCode}");
        throw Exception("Failed to create file in S3.");
      }
    } catch (e) {
      logger.e("Error creating Benchpress.json in S3: $e");
      rethrow;
    }
  }

  Future<bool> uploadScoreboard(String scoresJson) async {
    const bucketName = 'scoreboardbucketnesforgains-flutter';
    final region = dotenv.env['AWS_REGION'] ?? 'eu-north-1';
    final accessKeyId = dotenv.env['AWS_ACCESS_KEY_ID']!;
    final secretAccessKey = dotenv.env['AWS_SECRET_ACCESS_KEY']!;

    final credentials = AWSCredentials(accessKeyId, secretAccessKey);
    final awsSigner = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(credentials),
    );

    final endpoint = Uri.https(
      '$bucketName.s3.$region.amazonaws.com',
      '/Benchpress.json',
    );

    final content = scoresJson; // Use the JSON string as content

    // Validate JSON
    try {
      final testDecoded = jsonDecode(content);
      logger.i("Validated JSON structure: $testDecoded");
    } catch (e) {
      logger.e("Invalid JSON passed to upload: $e");
      return false;
    }

    final scope = AWSCredentialScope(region: region, service: AWSService.s3);

    final request = AWSHttpRequest(
      method: AWSHttpMethod.put,
      uri: endpoint,
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': utf8.encode(content).length.toString(),
      },
      body: utf8.encode(content), // Encode JSON to bytes
    );

    // Sign the request
    final signedRequest = await awsSigner.sign(
      request,
      credentialScope: scope,
    );

    // Debugging logs
    logger.i("Signed URI: ${signedRequest.uri}");
    logger.i("Signed Headers: ${signedRequest.headers}");
    logger.i("Request Body: $content");

    // Perform the PUT request
    final response = await http.put(
      signedRequest.uri,
      headers: signedRequest.headers,
      body: utf8.encode(content), // Send encoded JSON bytes
    );

    if (response.statusCode == 200) {
      logger.i("Benchpress.json successfully updated in S3.");
      return true;
    } else {
      logger
          .e("Failed to update Benchpress.json in S3: ${response.statusCode}");
      return false;
    }
  }
}
