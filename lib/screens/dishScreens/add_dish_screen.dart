import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/dish.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/dish_service.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:sqflite/sqflite.dart';

class AddDishScreen extends StatefulWidget {
  final Database sqflite;

  const AddDishScreen({super.key, required this.sqflite});

  @override
  State<AddDishScreen> createState() => _AddDishScreenState();
}

class _AddDishScreenState extends State<AddDishScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();

  late DishService nutritionService;

  @override
  void initState() {
    super.initState();
    nutritionService = DishService(widget.sqflite);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _submitNewDish() async {
    try {
      if (_formKey.currentState?.validate() ?? false) {
        final nutritionData = Dish(
          dish: _nameController.text,
          calories: int.tryParse(_caloriesController.text) ?? 0,
          protein: int.tryParse(_proteinController.text) ?? 0,
          carbohydrates: int.tryParse(_carbsController.text) ?? 0,
          fat: int.tryParse(_fatController.text) ?? 0,
        );

        final response = await nutritionService.addDish(
            nutritionData, AuthProvider.of(context).id);

        if (response.checksuccess == true) {
          _nameController.clear();
          _caloriesController.clear();
          _proteinController.clear();
          _carbsController.clear();
          _fatController.clear();

          if (mounted) {
            Navigator.pop(context, response.message);
          }
        } else {
          _nameController.clear();
          _caloriesController.clear();
          _proteinController.clear();
          _carbsController.clear();
          _fatController.clear();

          if (mounted) {
            Navigator.pop(context, '${response.message},red');
          }
        }
      }
    } catch (e) {
      logger.e('Error submitting', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppConstants.appbackgroundimage),
                fit: BoxFit.cover),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const CustomAppbar(
                  title: 'Add dish',
                ),
                const SizedBox(height: 40.0),
                CustomCards.buildFormCard(
                  context: context,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16.0),
                        _buildFormTextFormField(
                            controller: _nameController,
                            lable: 'Dish',
                            hint: 'Dish',
                            validatorText: 'Please enter a dish name'),
                        _buildFormTextFormField(
                          controller: _caloriesController,
                          lable: 'Calories',
                          hint: 'Calories',
                          validatorText: 'Please enter calories',
                          isNumeric: true,
                        ),
                        _buildFormTextFormField(
                            controller: _proteinController,
                            lable: 'Protein',
                            hint: 'Protein',
                            validatorText: 'Please enter protein',
                            isNumeric: true),
                        _buildFormTextFormField(
                          controller: _carbsController,
                          lable: 'Carbohydrates:',
                          hint: 'Carbohydrates:',
                          validatorText: 'Please enter carbohydrates',
                          isNumeric: true,
                        ),
                        _buildFormTextFormField(
                          controller: _fatController,
                          lable: 'Fat',
                          hint: 'Fat',
                          validatorText: 'Please enter fat',
                          isNumeric: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                CustomButtons.buildElevatedFunctionButton(
                    context: context,
                    onPressed: _submitNewDish,
                    text: 'Save Dish'),
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
      ),
    );
  }

  Widget _buildFormTextFormField({
    required TextEditingController controller,
    required String lable,
    required String hint,
    required String validatorText,
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: lable,
        hintText: hint,
        filled: true,
        fillColor: Colors.black54,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        if (isNumeric && int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }
}
