class WorkoutExercise {
  final String name;
  final int reps;
  final int sets;
  final double weight;

  WorkoutExercise({
    required this.name,
    required this.reps,
    required this.sets,
    required this.weight,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      name: json['name'],
      reps: json['reps'],
      sets: json['sets'],
      weight:
          (json['weight'] as num).toDouble(), // Ensures it's always a double
    );
  }
}
