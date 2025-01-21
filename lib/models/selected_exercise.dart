class SelectedExercise {
  final String name;
  final String reps;
  final String sets;
  final double weight;

  SelectedExercise({
    required this.name,
    required this.reps,
    required this.sets,
    required this.weight,
  });

  @override
  String toString() {
    return 'name: $name, reps: $reps, sets: $sets, weight: ${weight.toStringAsFixed(2)} kg';
  }
}
