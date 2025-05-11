import 'package:nesforgains/models/training_program/workoutday.dart';

class TrainingProgram {
  int id;
  String title;
  String description;
  int durationWeeks;
  int sessionsPerWeek;
  String difficulty;
  List<WorkoutDay> workouts;
  String date;

  TrainingProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.durationWeeks,
    required this.sessionsPerWeek,
    required this.difficulty,
    required this.workouts,
    required this.date,
  });

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    return TrainingProgram(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      durationWeeks: json['durationWeeks'],
      sessionsPerWeek: json['sessionsPerWeek'],
      difficulty: json['difficulty'],
      date: json['date'],
      workouts: (json['workouts'] as List<dynamic>)
          .map((day) => WorkoutDay.fromJson(day))
          .toList(),
    );
  }
}
