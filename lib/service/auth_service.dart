import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class AuthState extends ChangeNotifier {
  String id = '';
  String username = '';

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login(String id, String username) {
    this.id = id;
    this.username = username[0].toUpperCase() + username.substring(1);
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout(BuildContext context) {
    id = '';
    username = '';
    _isLoggedIn = false;
    notifyListeners();
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
