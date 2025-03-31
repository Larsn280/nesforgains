import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nesforgains/logger.dart';
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
}
