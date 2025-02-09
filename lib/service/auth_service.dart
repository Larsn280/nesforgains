import 'package:flutter/cupertino.dart';
import 'package:nesforgains/models/user_data.dart';
import 'package:nesforgains/service/secure_storage_service.dart';
import 'package:provider/provider.dart';

class AuthState extends ChangeNotifier {
  UserData loggedInUser = UserData(id: '', username: '', isloggedin: false);

  bool get isLoggedIn => loggedInUser.isloggedin!;

  // Method to initialize the AuthState from secure storage
  Future<void> initialize() async {
    final storedId = await SecureStorageService().read('user_id');
    final storedUsername = await SecureStorageService().read('username');

    if (storedId != null && storedUsername != null) {
      loggedInUser.id = storedId;
      loggedInUser.username = storedUsername;
      loggedInUser.isloggedin = true;
    }
    notifyListeners();
  }

  void login(String id, String username) {
    loggedInUser.id = id;
    loggedInUser.username = username[0].toUpperCase() + username.substring(1);
    loggedInUser.isloggedin = true;
    notifyListeners();
  }

  void logout(BuildContext context) async {
    // Clear the stored session from secure storage
    await SecureStorageService().deleteAll();

    // Reset local variables
    loggedInUser.id = '';
    loggedInUser.username = '';
    loggedInUser.isloggedin = false;

    // Notify listeners
    notifyListeners();

    // Navigate to the login screen
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  bool checkLoginStatus() {
    return loggedInUser.isloggedin!;
  }
}

class AuthProvider extends StatelessWidget {
  final Widget child;

  const AuthProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthState>(
      create: (_) => AuthState(),
      child: child,
    );
  }

  static AuthState of(BuildContext context) =>
      Provider.of<AuthState>(context, listen: false);
}
