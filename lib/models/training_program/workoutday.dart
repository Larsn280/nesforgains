import 'package:nesforgains/models/training_program/workout_exercise.dart';

class WorkoutDay {
  String day;
  List<WorkoutExercise> exercises;

  WorkoutDay({
    required this.day,
    required this.exercises,
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      day: json['day'],
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => WorkoutExercise.fromJson(e))
          .toList(),
    );
  }
}
