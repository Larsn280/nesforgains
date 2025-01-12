import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/login_service.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';

class LoginScreen extends StatefulWidget {
  final Database sqflite;

  const LoginScreen({super.key, required this.sqflite});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late LoginService loginService;
  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loginService = LoginService(widget.sqflite);
    _checkLoginState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Check if the user is already logged in and redirect to the home screen
  Future<void> _checkLoginState() async {
    final isLoggedIn = await loginService.isLoggedIn();
    if (isLoggedIn && mounted) {
      Navigator.pushReplacementNamed(context, '/homeScreen');
    }
  }

  /// Handle user login
  void _loginUser() async {
    try {
      if (_formKey.currentState!.validate()) {
        final response = await loginService.loginUser(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );
        if (response.username.isNotEmpty && mounted) {
          AuthProvider.of(context)
              .login(response.id, response.username.toString());
          Navigator.pushReplacementNamed(context, '/homeScreen');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.appbackgroundimage),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40.0),
              CustomCards.buildFormCard(
                context: context,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Login Screen',
                        style: AppConstants.headingStyle,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        key: const ValueKey('username'),
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          hintText: 'example@example.com',
                          filled: true,
                          fillColor: Colors.black45,
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid username.';
                          }
                          return null;
                        },
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        key: const ValueKey('password'),
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'password',
                          filled: true,
                          fillColor: Colors.black45,
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password.';
                          }
                          return null;
                        },
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              CustomButtons.buildElevatedFunctionButton(
                context: context,
                onPressed: _loginUser,
                text: 'Login',
              ),
              CustomButtons.buildElevatedFunctionButton(
                context: context,
                onPressed: () {
                  Navigator.pushNamed(context, '/registerScreen');
                },
                text: 'Register',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
