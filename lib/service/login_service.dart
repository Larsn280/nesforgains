import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nesforgains/models/user_data.dart';
import 'package:sqflite/sqflite.dart';

class LoginService {
  final Database _sqflite;
  static const _storage = FlutterSecureStorage();

  LoginService(this._sqflite);

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
