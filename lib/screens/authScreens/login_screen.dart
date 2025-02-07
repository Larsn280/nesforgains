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
  String usernameError = '';
  String passwordError = '';

  late LoginService loginService;

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
      // Reset error messages before validation
      setState(() {
        usernameError = _usernameController.text.isEmpty
            ? 'Vänligen ange ett användarnamn eller email.'
            : '';
        passwordError = _passwordController.text.isEmpty
            ? 'Vänligen ange ett lösenord.'
            : '';
      });

      // Proceed only if there are no input validation errors
      if (usernameError.isEmpty && passwordError.isEmpty) {
        final response = await loginService.loginUser(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );

        // Handle error cases based on response
        setState(() {
          if (response['success'] == false) {
            final error = response['error'];
            if (error == 'Fel användarnamn eller email.') {
              usernameError = error;
            } else if (error == 'Fel lösenord.') {
              passwordError = error;
            } else if (error.contains(',')) {
              // Handle both errors case
              final errors = error.split(',');
              usernameError = errors[0].trim();
              passwordError = errors[1].trim();
            }
          } else if (response['success'] == true) {
            // Login successful
            final user = response['user'];
            AuthProvider.of(context).login(user.id, user.username);
            Navigator.pushReplacementNamed(context, '/homeScreen');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppConstants.appbackgroundimage),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100.0),
                CustomCards.buildFormCard(
                  context: context,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Logga in',
                        style: AppConstants.headingStyle,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextFormField(
                        controller: _usernameController,
                        hintText: 'Användarnamn/Email',
                        textInputType: TextInputType.text,
                        icon: const Icon(Icons.person, color: Colors.white),
                        errorMessage: usernameError,
                        hasBorder: true,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextFormField(
                        controller: _passwordController,
                        hintText: 'Lösenord',
                        textInputType: TextInputType.text,
                        icon: const Icon(Icons.lock, color: Colors.white),
                        errorMessage: passwordError,
                        hasBorder: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                CustomButtons.buildElevatedFunctionButton(
                  context: context,
                  onPressed: _loginUser,
                  text: 'Logga in',
                ),
                CustomButtons.buildElevatedFunctionButton(
                  context: context,
                  onPressed: () async {
                    final result =
                        await Navigator.pushNamed(context, '/registerScreen');

                    if (result != null && result is String) {
                      List<String> credentials = result
                          .toString()
                          .split(',')
                          .map((e) => e.trim())
                          .toList();

                      if (credentials.length == 2) {
                        setState(() {
                          _usernameController.text = credentials[0]; // Email
                          _passwordController.text = credentials[1]; // Password
                        });
                      }
                    }
                  },
                  text: 'Registrera',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType textInputType,
    required Icon icon,
    required String errorMessage,
    required bool hasBorder,
  }) {
    BoxDecoration getBorderDecoration() {
      if (hasBorder) {
        return BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white, width: 1.0),
        );
      }
      return const BoxDecoration(color: Colors.black);
    }

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 12.0),
          decoration: getBorderDecoration(),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 13.0,
                color: Colors.grey,
              ),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              filled: true,
              fillColor: Colors.black,
              prefixIcon: icon,
            ),
            textAlignVertical: TextAlignVertical.center,
            keyboardType: textInputType,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        if (errorMessage != '')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 12.0),
            ),
          ),
      ],
    );
  }
}
