import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/user_data.dart';
import 'package:sqflite/sqflite.dart';

class LoginService {
  final String baseUrl = dotenv.env['API_GATEWAY_URL'] ??
      (throw Exception(
          'API_GATEWAY_URL is missing in .env. Please check your .env file.'));

  final String apiKey = dotenv.env['API_GATEWAY_KEY'] ??
      (throw Exception(
          'API_GATEWAY_KEY is missing in .env. Please check your .env file.'));

  final Database _sqflite;
  static const _storage = FlutterSecureStorage();

  LoginService(this._sqflite);

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
      } else {
        throw Exception('Error trying to log in');
      }

      return response;
    } catch (e) {
      throw Exception('Error trying to log in: $e');
    }
  }

  Future<Map<String, dynamic>> loginUser(
      String usernameOrEmail, String password) async {
    try {
      // Query the database for the user with the provided username/email and password
      final List<Map<String, dynamic>> results = await _sqflite.query(
        'AppUser',
        where: '(username = ? OR email = ?) AND password = ?',
        whereArgs: [
          usernameOrEmail.toLowerCase(),
          usernameOrEmail.toLowerCase(),
          password,
        ],
      );

      // If no matching user is found
      if (results.isEmpty) {
        // Check if username/email exists
        final List<Map<String, dynamic>> userCheck = await _sqflite.query(
          'AppUser',
          where: '(username = ? OR email = ?)',
          whereArgs: [
            usernameOrEmail.toLowerCase(),
            usernameOrEmail.toLowerCase(),
          ],
        );

        if (userCheck.isEmpty) {
          return {'success': false, 'error': 'Fel användarnamn eller email.'};
        } else {
          return {'success': false, 'error': 'Fel lösenord.'};
        }
      }

      // User found, return success and user data
      final user = results.first;
      final userData = UserData(
        id: user['id'] as String,
        username: user['username'] as String,
      );

      // Save the user session securely
      await _storage.write(key: 'user_id', value: userData.id);
      await _storage.write(key: 'username', value: userData.username);

      return {'success': true, 'user': userData};
    } catch (e) {
      throw Exception('Error logging in user: $e');
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
