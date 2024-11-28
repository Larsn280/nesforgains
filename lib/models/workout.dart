import 'package:nesforgains/models/exercise.dart';

class Workout {
  int id;

  late String name;

  String? date;

  String? userId;

  String? markedColor;

  List<Exercise>? exercises;

  Workout(
      {required this.id,
      required this.name,
      required this.date,
      required this.userId,
      this.markedColor,
      this.exercises});
}
