import 'package:nesforgains/models/ingredient.dart';
import 'package:nesforgains/models/stage.dart';

class Recipe {
  int? id; // Automatically generated unique ID
  String? title; // Recipe title (e.g. "Spaghetti Carbonara")
  String? description; // Optional description of the recipe
  int? duration; // Duration in minutes (e.g., 30 mins)
  String? difficulty; // Difficulty level (e.g., "Easy", "Medium", "Hard")
  List<Ingredient>? ingredients;
  List<Stage>? stages;
  // final categories = IsarLinks<Category>();     // Linking to categories like "Italian", "Vegetarian"
  String? createdAt; // Date when the recipe was created
  String? updatedAt; // Date when the recipe was last updated

  Recipe(
      {this.id,
      this.title,
      this.description,
      this.duration,
      this.difficulty,
      this.ingredients,
      this.stages,
      this.createdAt,
      this.updatedAt});
}
