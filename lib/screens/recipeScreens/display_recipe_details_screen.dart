import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/recipe.dart';
import 'package:nesforgains/screens/recipeScreens/edit_recipe_screen.dart';
import 'package:nesforgains/service/recipe_service.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:nesforgains/widgets/custom_snackbar.dart';
import 'package:sqflite/sqflite.dart';

class DisplayRecipeDetailsScreen extends StatefulWidget {
  final Database sqflite;
  final Recipe recipe;
  const DisplayRecipeDetailsScreen(
      {super.key, required this.recipe, required this.sqflite});

  @override
  State<DisplayRecipeDetailsScreen> createState() =>
      _DisplayRecipeScreenState();
}

class _DisplayRecipeScreenState extends State<DisplayRecipeDetailsScreen> {
  late RecipeService recipeService;
  late Recipe recipe;

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
    recipeService = RecipeService(widget.sqflite);
  }

  Future<Recipe> _fetchRecipe() async {
    try {
      final fetchedRecipe =
          await recipeService.fetchRecipeById(widget.recipe.id!);
      return fetchedRecipe;
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
      throw Exception('$e ,$stackTrace');
    }
  }

  void _handleDeleteRecipe(Recipe recipe) async {
    try {
      final result = await recipeService.deleteRecipe(recipe);

      if (result.checksuccess == true) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
      CustomSnackbar.showSnackBar(message: result.message);
    } catch (e, stackTrace) {
      logger.e('An error occurred while deleting the recipe: $e',
          stackTrace: stackTrace);

      CustomSnackbar.showSnackBar(
          message:
              'An error occurred while deleting the recipe. Please try again.');
    }
  }

  void _navigateToEditRecipe(Recipe recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRecipeScreen(
          recipe: recipe,
          sqflite: widget.sqflite,
        ),
      ),
    );
    if (result == true) {
      final updatedRecipe = await _fetchRecipe();
      setState(() {
        this.recipe = updatedRecipe;
      });
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
                const CustomAppbar(title: 'Recipe Details'),
                const SizedBox(
                  height: 40.0,
                ),
                CustomCards.buildListCard(
                    context: context,
                    child: SingleChildScrollView(
                      child: _buildRecipeDetails(recipe),
                    )),
                const SizedBox(height: 8.0),
                CustomButtons.buildElevatedFunctionButton(
                    context: context,
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    text: 'Back'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeDetails(Recipe recipe) {
    final ingredients = recipe.ingredients!.map((i) => i).toList();
    final stages = recipe.stages!.map((i) => i.instruction).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              recipe.title!,
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.greenAccent),
              onPressed: () {
                _navigateToEditRecipe(recipe);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                _handleDeleteRecipe(recipe);
              },
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(
          'Duration: ${recipe.duration} min',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        Text(
          'Difficulty: ${recipe.difficulty}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        const SizedBox(
          height: 30.0,
        ),
        ingredients.isNotEmpty
            ? SizedBox(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(0),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = ingredients[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}. ',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          Expanded(
                            child: Text(
                              ingredient.name!,
                              style: const TextStyle(
                                  fontSize: 14.0, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            : const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    child: Text(
                      'No ingredients to show...',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ),
              ),
        const SizedBox(
          height: 10.0,
        ),
        stages.isNotEmpty
            ? SizedBox(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(0),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stages.length,
                  itemBuilder: (context, index) {
                    final stage = stages[index];
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text(
                              'Steg ${index + 1}: ',
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Text(
                                stage!,
                                style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 5,
                              ),
                            ),
                          ],
                        ));
                  },
                ),
              )
            : const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    child: Text(
                      'No stages to show...',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
