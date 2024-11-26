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

  Future<Map<String, dynamic>?> downloadScoreboard() async {
    const bucketName = 'scoreboardbucketnesforgains-flutter';
    final region =
        dotenv.env['AWS_REGION'] ?? 'eu-north-1'; // Get region from .env
    final accessKeyId = dotenv.env['AWS_ACCESS_KEY_ID']!;
    final secretAccessKey = dotenv.env['AWS_SECRET_ACCESS_KEY']!;

    // Create AWS credentials from the environment
    final credentials = AWSCredentials(accessKeyId, secretAccessKey);
    final awsSigner = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(credentials),
    );

    // The endpoint to get the file
    final endpoint = Uri.https(
      '$bucketName.s3.$region.amazonaws.com',
      '/Benchpress.json', // The file you want to get
    );

    // Create the signing scope
    final scope = AWSCredentialScope(region: region, service: AWSService.s3);

    // Create the HTTP request
    final request = AWSHttpRequest(
      method: AWSHttpMethod.get,
      uri: endpoint,
    );

    // Sign the request
    final signedRequest = await awsSigner.sign(
      request,
      credentialScope: scope,
    );

    // Perform the HTTP request
    final response = await http.get(
      signedRequest.uri,
      headers: signedRequest.headers,
    );

    // Handle the response
    if (response.statusCode == 200) {
      // Parse and return the JSON content
      return jsonDecode(response.body);
    } else {
      logger.e('Failed to download file: ${response.statusCode}');
      return null;
    }
  }
}
