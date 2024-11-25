class Ingredient {
  int? id;
  int? recipeId;
  String? name; // Ingredient name (e.g., "Flour", "Eggs")
  String? unit; // Unit (e.g., "grams", "ml", "pieces")
  double? quantity; // Quantity of the ingredient (e.g., "200 grams")
  String? note; // Optional note (e.g., "chopped finely")

  Ingredient(
      {this.id, this.recipeId, this.name, this.unit, this.quantity, this.note});
}
