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

  void _createNewUser() async {
    try {
      setState(() {
        emailError =
            _emailController.text.isEmpty ? 'Vänligen ange en email.' : '';
        passwordError = _passwordController.text.isEmpty
            ? 'Vänligen ange ett lösenord'
            : '';
      });

      if (emailError.isEmpty && passwordError.isEmpty) {
        final response = await registerService.createNewUser(
            _emailController.text.trim(), _passwordController.text.trim());
        logger.i(response);
        logger.i('Username: ${_emailController.text}');
        logger.i('Password: ${_passwordController.text}');

        // Handle error cases based on response
        setState(() {
          if (response['success'] == false) {
            final error = response['error'];
            if (error == 'Ogiltig emailadress: ${_emailController.text}') {
              emailError = error;
            } else if (error ==
                'Användaren med email: ${_emailController.text} finns redan!') {
              emailError = error;
            }
          } else if (response['success'] == true) {
            // Login successful
            CustomSnackbar.showSnackBar(
                message: '${_emailController.text.toString()} was registered.');
            if (mounted) {
              Navigator.pop(context,
                  '${_emailController.text}, ${_passwordController.text}');
            }
          }
        });
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
                  ],
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              CustomButtons.buildElevatedFunctionButton(
                  context: context,
                  onPressed: _createNewUser,
                  text: 'Registrera'),
              CustomButtons.buildElevatedFunctionButton(
                  context: context,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Tillbaka'),
            ],
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
