import 'dart:convert';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nesforgains/logger.dart';

class AwsBucketService {
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
