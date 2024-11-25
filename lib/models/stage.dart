class Stage {
  int? id;
  int? stageNumber; // Step number (e.g., 1, 2, 3)
  int? recipeId;
  String? instruction; // Step description (e.g., "Boil water")
  int?
      duration; // Optional duration for this step in minutes (e.g., 5 minutes for boiling)

  Stage(
      {this.id,
      this.stageNumber,
      this.recipeId,
      this.instruction,
      this.duration});
}
