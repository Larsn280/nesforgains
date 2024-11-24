import 'package:sqflite/sqflite.dart';

class RegisterService {
  final Database sqflite;

  RegisterService(this.sqflite);

  // Check if email already exists in the database.
  Future<bool> checkIfUserExists(String email) async {
    // Query the database for a user with the given email
    final List<Map<String, dynamic>> results = await sqflite.query(
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
  Future<String> createNewUser(String email, String password) async {
    try {
      // Validate email format
      if (!isValidEmail(email)) {
        return '$email is an invalid email format';
      }

      // Check if user already exists
      final userExists = await checkIfUserExists(email);

      if (userExists) {
        return 'User with email: $email already exists!';
      } else {
        // Generate a username from the email
        List<String> parts = email.split('@');
        String newUsername = parts[0].toLowerCase();

        // Insert the new user into the database
        await sqflite.insert(
          'AppUser',
          {
            'email': email.toLowerCase(),
            'username': newUsername,
            'password': password,
            'age': 0, // Default age value
          },
        );

        return '$email was created!';
      }
    } catch (e) {
      throw Exception('Error creating new user: $e');
    }
  }
}
