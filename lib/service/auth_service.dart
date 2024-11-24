import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class AuthState extends ChangeNotifier {
  int id = 0;
  String username = '';

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login(int id, String username) {
    this.id = id;
    this.username = username;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    id = 0;
    username = '';
    _isLoggedIn = false;
    notifyListeners();
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
