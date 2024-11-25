import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/dish.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/dish_service.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:nesforgains/widgets/custom_snackbar.dart';
import 'package:sqflite/sqflite.dart';

class EditDishScreen extends StatefulWidget {
  final Database sqflite;
  final Dish dish;

  const EditDishScreen({super.key, required this.sqflite, required this.dish});

  @override
  State<EditDishScreen> createState() => _EditDishScreenState();
}

class _EditDishScreenState extends State<EditDishScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _calorieController;
  late TextEditingController _proteinController;
  late TextEditingController _carbController;
  late TextEditingController _fatController;
  String olddishname = '';

  late DishService dishService;
  late Dish newDish;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with existing data
    _nameController = TextEditingController(text: widget.dish.dish);
    setState(() {
      olddishname = widget.dish.dish.toString();
    });
    _calorieController =
        TextEditingController(text: widget.dish.calories.toString());
    _proteinController =
        TextEditingController(text: widget.dish.protein.toString());
    _carbController =
        TextEditingController(text: widget.dish.carbohydrates.toString());
    _fatController = TextEditingController(text: widget.dish.fat.toString());

    dishService = DishService(widget.sqflite);
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    _nameController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _editDish() async {
    try {
      if (_formKey.currentState!.validate()) {
        newDish = Dish(
            dish: _nameController.text,
            calories: int.tryParse(_calorieController.text) ?? 0,
            protein: int.tryParse(_proteinController.text) ?? 0,
            carbohydrates: int.tryParse(_carbController.text) ?? 0,
            fat: int.tryParse(_fatController.text) ?? 0);
        final response = await dishService.editDish(
            newDish, olddishname, AuthProvider.of(context).id);

        if (response.checksuccess == true) {
          if (mounted) {
            Navigator.pop(context, true);
          }
        }

        CustomSnackbar.showSnackBar(message: response.message);
      }
    } catch (e) {
      logger.e('Error editing', error: e);

      CustomSnackbar.showSnackBar(
          message:
              'An error occurred while editing the dish. Please try again.');
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomAppbar(
                  title: 'Edit Dish',
                ),
                const SizedBox(
                  height: 40.0,
                ),
                CustomCards.buildFormCard(
                  context: context,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 16.0),
                        _buildFormTextFormField(
                            controller: _nameController,
                            lable: 'Dish',
                            validatorText: 'Please enter a name'),
                        _buildFormTextFormField(
                            controller: _calorieController,
                            lable: 'Calories',
                            validatorText:
                                'Please enter the number of calories',
                            isNumeric: true),
                        _buildFormTextFormField(
                            controller: _proteinController,
                            lable: 'Protein',
                            validatorText: 'Please enter the number of protein',
                            isNumeric: true),
                        _buildFormTextFormField(
                            controller: _calorieController,
                            lable: 'Carbohydrates',
                            validatorText:
                                'Please enter the number of carbohydrates',
                            isNumeric: true),
                        _buildFormTextFormField(
                            controller: _fatController,
                            lable: 'Fat',
                            validatorText: 'Please enter the number of fat',
                            isNumeric: true),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomButtons.buildElevatedFunctionButton(
                    context: context, onPressed: _editDish, text: 'Save'),
                CustomButtons.buildElevatedFunctionButton(
                    context: context,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: 'Cancle'),
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
    required String validatorText,
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: lable,
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
