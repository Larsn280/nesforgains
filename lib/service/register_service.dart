import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/temp_usertransfer.dart';
import 'package:nesforgains/models/user_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class RegisterService {
  final String baseUrl = dotenv.env['API_GATEWAY_URL'] ??
      (throw Exception(
          'API_GATEWAY_URL is missing in .env. Please check your .env file.'));

  final String apiKey = dotenv.env['API_GATEWAY_KEY'] ??
      (throw Exception(
          'API_GATEWAY_KEY is missing in .env. Please check your .env file.'));

  final Database _sqflite;
  var uuid = const Uuid();

  RegisterService(this._sqflite);

  Future<http.Response> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-api-key': apiKey,
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        logger.i('Registered user successfully');
      }

      return response;
    } catch (e) {
      throw Exception('Error trying to register: $e');
    }
  }

  Future<http.Response> registerFromSqflite(
      String sk, String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transfer'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-api-key': apiKey,
        },
        body: json.encode({
          'sk': sk,
          'userName': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        logger.i('Registered users successfully');
      }

      return response;
    } catch (e) {
      throw Exception('Error trying to register: $e');
    }
  }

  Future<List<TempUsertransfer>> getSqfliteAllUsers() async {
    try {
      final users = await _sqflite.query('AppUser');

      List<TempUsertransfer> userList = [];

      for (var user in users) {
        String sk =
            user['id'].toString(); // Replace 'sk' with actual column name
        String email = user['email'].toString();
        String password = user['password'].toString();
        String username = user['username'].toString();

        if (sk.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
          await registerFromSqflite(sk, username, email, password);
          userList.add(TempUsertransfer(
              id: sk, username: username, email: email, password: password));
        }
      }

      return userList;
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // Check if email already exists in the database.
  Future<bool> checkIfUserExists(String email) async {
    // Query the database for a user with the given email
    final List<Map<String, dynamic>> results = await _sqflite.query(
      'AppUser',
      where: 'email = ?', // Use parameterized query to prevent SQL injection
      whereArgs: [email.toLowerCase()],
    );

    return results.isNotEmpty;
  }

  // Regular expression to validate standard email format.
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Create a new user if they don't already exist.
  Future<Map<String, dynamic>> createNewUser(
      String email, String password) async {
    try {
      // Validate email format
      if (!isValidEmail(email)) {
        return {
          "success": false,
          "error": "Ogiltig emailadress: $email",
        };
      }

      // Check if user already exists
      final userExists = await checkIfUserExists(email);
      if (userExists) {
        return {
          "success": false,
          "error": "Användaren med email: $email finns redan!",
        };
      }

      // Generate new user ID and username
      String newUserId = uuid.v4();
      List<String> parts = email.split('@');
      String newUsername = parts[0].toLowerCase();

      // Insert new user into the database
      await _sqflite.insert(
        'AppUser',
        {
          'id': newUserId,
          'email': email.toLowerCase(),
          'username': newUsername,
          'password': password,
          'age': 0, // Default age value
        },
      );

      return {
        "success": true,
        "message": "$email har registrerats!",
      };
    } catch (e) {
      return {
        "success": false,
        "error": "Ett fel uppstod vid registrering: $e",
      };
    }
  }
}
