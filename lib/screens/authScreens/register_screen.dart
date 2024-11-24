import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/service/register_service.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:nesforgains/widgets/custom_snackbar.dart';
import 'package:sqflite/sqflite.dart';

class RegisterScreen extends StatefulWidget {
  final Database sqflite;

  const RegisterScreen({super.key, required this.sqflite});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late RegisterService registerService;

  @override
  void initState() {
    super.initState();
    registerService = RegisterService(widget.sqflite);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createNewUser() async {
    try {
      if (_formKey.currentState!.validate()) {
        String response = await registerService.createNewUser(
            _emailController.text.toString(),
            _passwordController.text.toString());
        logger.i(response);
        logger.i('Username: ${_emailController.text}');
        logger.i('Password: ${_passwordController.text}');

        CustomSnackbar.showSnackBar(
            message: '${_emailController.text.toString()} was registered.');
        if (response != '') {
          if (mounted) {
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      logger.w('Error creating user', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(AppConstants.appbackgroundimage),
              fit: BoxFit.cover),
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
                        'Register Screen',
                        style: AppConstants.headingStyle,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'example@examplesson.com',
                          filled: true,
                          fillColor: Colors.black54,
                          prefixIcon: Icon(Icons.mail, color: Colors.white),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter valid email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter valid email';
                          }
                          return null;
                        },
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter yout password',
                          filled: true,
                          fillColor: Colors.black54,
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 32.0,
              ),
              CustomButtons.buildElevatedFunctionButton(
                  context: context,
                  onPressed: _createNewUser,
                  text: 'Register'),
              CustomButtons.buildElevatedFunctionButton(
                  context: context,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Go back'),
            ],
          ),
        ),
      ),
    );
  }
}
