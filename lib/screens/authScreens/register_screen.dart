import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/service/register_service.dart';
import 'package:nesforgains/widgets/custom_button.dart';
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
  String emailError = '';
  String passwordError = '';

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

  Future<void> _createNewUser() async {
    try {
      // Set error messages based on form validation
      setState(() {
        emailError =
            _emailController.text.isEmpty ? 'Please enter an email.' : '';
        passwordError =
            _passwordController.text.isEmpty ? 'Please enter a password.' : '';
      });

      if (emailError.isEmpty && passwordError.isEmpty) {
        final response = await registerService.register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Check the response from the API
        if (response.statusCode == 201) {
          // Registration successful
          CustomSnackbar.showSnackBar(
            message: '${_emailController.text} was successfully registered.',
          );
          if (mounted) {
            Navigator.pop(context, _emailController.text);
          }
        } else {
          // Registration failed; handle different error cases
          final responseBody = json.decode(response.body);
          String errorMessage =
              responseBody['message'] ?? 'Unknown error occurred';

          setState(() {
            // Handle specific errors based on the message returned
            if (errorMessage.contains('Email already exists')) {
              emailError = errorMessage;
            } else if (errorMessage.contains('Username already exists')) {
              emailError =
                  errorMessage; // Could also be usernameError if you want
            } else if (errorMessage.contains('Invalid email format')) {
              emailError = errorMessage;
            } else {
              // Generic fallback if no specific error is detected
              emailError = 'An error occurred. Please try again.';
            }
          });
        }
      }
    } catch (e) {
      // Catch any unexpected errors
      logger.w('Error creating user', error: e);
      setState(() {
        emailError = 'Something went wrong. Please try again later.';
      });
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
                fit: BoxFit.cover),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 100.0,
                ),
                CustomCards.buildFormCard(
                  context: context,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Ny användare',
                        style: AppConstants.headingStyle,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextFormField(
                          controller: _emailController,
                          hintText: 'Email',
                          textInputType: TextInputType.text,
                          icon: const Icon(Icons.mail, color: Colors.white),
                          errorMessage: emailError,
                          hasBorder: true),
                      const SizedBox(
                        height: 16.0,
                      ),
                      _buildTextFormField(
                          controller: _passwordController,
                          hintText: 'Lösenord',
                          textInputType: TextInputType.text,
                          icon: const Icon(Icons.lock, color: Colors.white),
                          errorMessage: passwordError,
                          hasBorder: true),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Wrap(
                        spacing: 40,
                        children: [
                          CustomButton(
                            onPressed: _createNewUser,
                            text: 'Registrera',
                            width: 120,
                          ),
                          CustomButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            text: 'Tillbaka',
                            width: 120,
                          ),
                        ],
                      ),
                    ],
                  ),
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
