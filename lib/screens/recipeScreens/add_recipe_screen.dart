import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/ingredient.dart';
import 'package:nesforgains/models/recipe.dart';
import 'package:nesforgains/models/stage.dart';
import 'package:nesforgains/service/recipe_service.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:nesforgains/widgets/custom_snackbar.dart';
import 'package:sqflite/sqflite.dart';

class AddRecipeScreen extends StatefulWidget {
  final Database sqflite;

  const AddRecipeScreen({super.key, required this.sqflite});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();

  late RecipeService recipeService;

  @override
  void initState() {
    super.initState();
    recipeService = RecipeService(widget.sqflite);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _difficultyController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  void _handleSaveRecipe() async {
    try {
      // Validate the form
      if (_formKey.currentState!.validate()) {
        final List<Ingredient> ingredientsList = [];
        final List<Stage> stageList = [];

        final recipe = Recipe()
          ..title = _titleController.text
          ..description = _descriptionController.text
          ..duration = int.parse(_durationController.text)
          ..difficulty = _difficultyController.text;

        final splitIngredientList =
            _ingredientsController.text.split(','); // Input like "Flour, Eggs"
        final splitStageList = _stepsController.text
            .split('.'); // Input like "Boil water. Add pasta."

        for (var ingredientText in splitIngredientList) {
          final ingredient = Ingredient()
            ..name = ingredientText.trim() // Remove any extra spaces
            ..quantity =
                1 // Default quantity, you can extend this for user input
            ..unit = 'unit'; // Default unit
          ingredientsList.add(ingredient);
        }

        for (int i = 0; i < splitStageList.length; i++) {
          final stage = Stage()
            ..stageNumber = i + 1
            ..instruction = splitStageList[i].trim();
          stageList.add(stage);
        }

        final result =
            await recipeService.addRecipe(recipe, ingredientsList, stageList);

        CustomSnackbar.showSnackBar(message: result.message);

        // Clear the form fields
        _formKey.currentState!.reset();
      }
    } catch (e, stackTrace) {
      logger.e('Error adding recipe: $e', stackTrace: stackTrace);

      CustomSnackbar.showSnackBar(
          message:
              'An error occurred while adding the recipe. Please try again.');
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
                  title: 'Add new recipe',
                ),
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
                        const SizedBox(height: 16.0),
                        // Title Input
                        _buildTextFormField(
                            controller: _titleController,
                            labelText: 'Title',
                            validatorMessage: 'Please enter the recipe title'),

                        // Description Input
                        _buildTextFormField(
                            controller: _descriptionController,
                            labelText: 'Description',
                            validatorMessage: 'Please enter a description'),

                        // Duration Input
                        _buildTextFormField(
                          controller: _durationController,
                          labelText: 'Duration (in minutes)',
                          validatorMessage: 'Please enter the duration',
                          keyboardType: TextInputType.number,
                          isNumeric: true,
                        ),

                        // Difficulty Input
                        _buildTextFormField(
                            controller: _difficultyController,
                            labelText: 'Difficulty',
                            validatorMessage: 'Please enter the difficulty'),

                        // Ingredients Input
                        _buildTextFormField(
                            controller: _ingredientsController,
                            labelText: 'Ingredients (comma separated)',
                            validatorMessage:
                                'Please enter at least one ingredient'),

                        // Steps Input
                        _buildTextFormField(
                            controller: _stepsController,
                            labelText: 'Steps (period separated)',
                            validatorMessage: 'Please enter the steps'),
                      ],
                    ),
                  ),
                ),

                // Save Button
                const SizedBox(height: 8.0),
                CustomButtons.buildElevatedFunctionButton(
                    context: context,
                    onPressed: _handleSaveRecipe,
                    text: 'Save Recipe'),
                CustomButtons.buildElevatedFunctionButton(
                    context: context,
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    text: 'Back')
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String validatorMessage,
    TextInputType keyboardType = TextInputType.text,
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.black54,
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        } else if (isNumeric && int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }
}
