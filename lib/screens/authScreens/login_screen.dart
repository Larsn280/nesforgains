import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/login_service.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
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

  @override
  void initState() {
    super.initState();
    loginService = LoginService(widget.sqflite);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginUser() async {
    try {
      if (_formKey.currentState!.validate()) {
        final response = await loginService.loginUser(
            _usernameController.text.toString(),
            _passwordController.text.toString());
        if (response.username != '') {
          // Håll koll på.
          if (mounted) {
            AuthProvider.of(context)
                .login(response.id, response.username.toString());
          }
        }
      }
    } catch (e) {
      // logger.e('Error logging in user', error: e);
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
              const SizedBox(
                height: 40.0,
              ),
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
                          hintText: 'exemple@example.com',
                          filled: true,
                          fillColor: Colors.black45,
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter valid username.';
                          }
                          return null;
                        },
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
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
                            return 'Please enter password.';
                          }
                          return null;
                        },
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 32.0,
              ),
              CustomButtons.buildElevatedFunctionButton(
                  context: context, onPressed: _loginUser, text: 'Login'),
              CustomButtons.buildElevatedFunctionButton(
                  context: context,
                  onPressed: () {
                    Navigator.pushNamed(context, '/registerScreen');
                  },
                  text: 'Register'),
            ],
          ),
        ),
      ),
    );
  }
}
