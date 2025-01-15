import 'package:flutter/cupertino.dart';
import 'package:nesforgains/service/secure_storage_service.dart';
import 'package:provider/provider.dart';

class AuthState extends ChangeNotifier {
  String id = '';
  String username = '';

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  // Method to initialize the AuthState from secure storage
  Future<void> initialize() async {
    final storedId = await SecureStorageService().read('user_id');
    final storedUsername = await SecureStorageService().read('username');

    if (storedId != null && storedUsername != null) {
      id = storedId;
      username = storedUsername;
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  void login(String id, String username) {
    this.id = id;
    this.username = username[0].toUpperCase() + username.substring(1);
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout(BuildContext context) async {
    // Clear the stored session from secure storage
    await SecureStorageService().deleteAll();

    // Reset local variables
    id = '';
    username = '';
    _isLoggedIn = false;

    // Notify listeners
    notifyListeners();

    // Navigate to the login screen
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  bool checkLoginStatus() {
    return _isLoggedIn;
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
