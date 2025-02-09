import 'package:nesforgains/models/exercise_data.dart';

class WorkoutData {
  int id;

  late String name;

  String? date;

  String? userId;

  String? markedColor;

  List<ExerciseData>? exercises;

  WorkoutData(
      {required this.id,
      required this.name,
      required this.date,
      required this.userId,
      this.markedColor,
      this.exercises});
}
