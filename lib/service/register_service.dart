import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nesforgains/logger.dart';
import 'package:http/http.dart' as http;

class RegisterService {
  final String baseUrl = dotenv.env['API_GATEWAY_URL'] ??
      (throw Exception(
          'API_GATEWAY_URL is missing in .env. Please check your .env file.'));

  final String apiKey = dotenv.env['API_GATEWAY_KEY'] ??
      (throw Exception(
          'API_GATEWAY_KEY is missing in .env. Please check your .env file.'));

  RegisterService();

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
}
