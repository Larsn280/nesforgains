import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:nesforgains/logger.dart';

class LoginService {
  final String baseUrl = dotenv.env['API_GATEWAY_URL'] ??
      (throw Exception(
          'API_GATEWAY_URL is missing in .env. Please check your .env file.'));

  final String apiKey = dotenv.env['API_GATEWAY_KEY'] ??
      (throw Exception(
          'API_GATEWAY_KEY is missing in .env. Please check your .env file.'));

  static const _storage = FlutterSecureStorage();

  Future<http.Response> login(String userNameOrEmail, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'), // Replace with your actual login URL
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-api-key': apiKey, // If using API key
        },
        body: json.encode({
          'userName': userNameOrEmail,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        logger.i('Login successful');
        final body = json.decode(response.body);
        final user = body['user'];

        // Save the user session securely
        await _storage.write(key: 'user_id', value: user['sk']);
        await _storage.write(key: 'username', value: user['userName']);
        await _storage.write(key: 'email', value: user['email']);
      }

      return response;
    } catch (e) {
      throw Exception('Error trying to log in: $e');
    }
  }

  Future<void> logoutUser() async {
    // Clear the stored session
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final userId = await _storage.read(key: 'user_id');
    return userId != null;
  }
}
