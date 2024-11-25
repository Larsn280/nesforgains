import 'package:nesforgains/models/user_data.dart';
import 'package:sqflite/sqflite.dart';

class LoginService {
  final Database _sqflite;

  LoginService(this._sqflite);

  Future<UserData> loginUser(String usernameOrEmail, String password) async {
    try {
      // Query the database for users matching the username/email
      final List<Map<String, dynamic>> results = await _sqflite.query(
        'AppUser', // The table name
        where:
            '(username = ? OR email = ?) AND password = ?', // SQL WHERE clause
        whereArgs: [
          usernameOrEmail.toLowerCase(),
          usernameOrEmail.toLowerCase(),
          password
        ],
      );

      if (results.isEmpty) {
        throw Exception('Invalid username/email or password.');
      } else if (results.length > 1) {
        throw Exception('Multiple users found with the same username/email.');
      }

      // Map the result to a `UserData` object
      final user = results.first;
      return UserData(
        id: user['id'] as int,
        username: user['username'] as String,
      );
    } catch (e) {
      throw Exception('Error logging in user: $e');
    }
  }
}
