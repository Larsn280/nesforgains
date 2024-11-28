class Nutrition {
  int? id;
  String? date;
  final int calories;
  final int protein;
  final int carbohydrates;
  final int fat;
  String? userId;

  Nutrition({
    this.id,
    this.date,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.userId,
  });
}
