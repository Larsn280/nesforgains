import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/exercise.dart';
import 'package:nesforgains/models/response_data.dart';
import 'package:nesforgains/models/workout.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutService {
  final Database _sqflite;

  WorkoutService(this._sqflite);

  Future<ResponseData> addWorkout(
      Workout workout, List<Exercise> exercises) async {
    try {
      // Helper to parse the date
      String parseDate(String dateTime) => dateTime.split(' ')[0];

      // Validate date
      if (workout.date == '') {
        return ResponseData(
          checksuccess: false,
          message: 'Invalid date. Please provide a valid date for the workout.',
        );
      }

      final String date = parseDate(workout.date!);

      // Check if the workout already exists
      final existingWorkouts = await _sqflite.query(
        'Workout',
        where: 'name = ? AND userId = ? AND date = ?',
        whereArgs: [workout.name, workout.userId, date],
      );

      if (existingWorkouts.isEmpty) {
        // Start a transaction to ensure data integrity
        await _sqflite.transaction((txn) async {
          // Insert workout into the workouts table
          final workoutId = await txn.insert(
            'Workout',
            {
              'name': workout.name,
              'userId': workout.userId,
              'date': date,
            },
          );

          // Insert exercises into the exercises table
          for (final exercise in exercises) {
            await txn.insert(
              'Exercise',
              {
                'name': exercise.name,
                'workoutId': workoutId,
                'kg': exercise.kg,
                'reps': exercise.rep,
                'sets': exercise.set,
              },
            );
          }
        });

        return ResponseData(
          checksuccess: true,
          message:
              'Successfully added workout: ${workout.name}: ${workout.date}',
        );
      }

      // If workout already exists, respond accordingly
      return ResponseData(
        checksuccess: false,
        message: 'Workout already logged: ${workout.name}: ${workout.date}',
      );
    } catch (e) {
      return ResponseData(
        checksuccess: false,
        message:
            'An error occurred while trying to add the workout: ${e.toString()}',
      );
    }
  }

  Future<List<Workout>> fetchAllWorkouts(int userId) async {
    try {
      // Fetch workouts along with their exercises in one query using JOIN
      final List<Map<String, dynamic>> rows = await _sqflite.rawQuery(
        '''
  SELECT Workout.*, Exercise.id AS exercise_id, Exercise.name AS exercise_name,
         Exercise.kg, Exercise.reps, Exercise.sets, Exercise.workoutId
  FROM Workout
  LEFT JOIN Exercise ON Workout.id = Exercise.workoutId
  WHERE Workout.userId = ?
  ORDER BY Workout.date DESC
  ''',
        [userId],
      );

      // Create a map to store workouts by id
      Map<int, Workout> workoutMap = {};

      // Process the query results
      for (final row in rows) {
        final workoutId = row['id'];
        final exercise = Exercise(
          id: row['exercise_id'],
          name: row['exercise_name'],
          workoutId: row['workoutId'],
          kg: row['kg'],
          rep: row['reps'],
          set: row['sets'],
        );

        // Check if the workout already exists in the map, if not, create a new one
        if (!workoutMap.containsKey(workoutId)) {
          workoutMap[workoutId] = Workout(
            id: workoutId,
            name: row['name'],
            userId: row['userId'],
            date: row['date'],
            markedColor: row['markedColor'],
            exercises: [],
          );
        }

        // Add the exercise to the corresponding workout
        workoutMap[workoutId]?.exercises?.add(exercise);
      }

      // Convert the map values (workouts) to a list and return
      return workoutMap.values.toList();
    } catch (e) {
      logger.e('Error when trying to fetch workouts: $e');
      return []; // Return an empty list on error
    }
  }

  Future<Workout> fetchWorkoutById(int? workoutId) async {
    try {
      // Fetch the workout by ID
      final List<Map<String, dynamic>> workoutRows = await _sqflite.query(
        'Workout',
        where: 'id = ?',
        whereArgs: [workoutId],
      );

      if (workoutRows.isEmpty) {
        throw Exception('Workout not found for ID $workoutId');
      }

      // There should be only one workout
      final workoutRow = workoutRows.first;

      // Fetch exercises for this workout
      final List<Map<String, dynamic>> exerciseRows = await _sqflite.query(
        'Exercise',
        where: 'workoutId = ?',
        whereArgs: [workoutId],
      );

      // Manually map exercises
      List<Exercise> exercises = [];
      for (final exerciseRow in exerciseRows) {
        exercises.add(Exercise(
          id: exerciseRow['id'],
          name: exerciseRow['name'],
          workoutId: exerciseRow['workoutId'],
          kg: exerciseRow['kg'],
          rep: exerciseRow['reps'],
          set: exerciseRow['sets'],
        ));
      }

      // Create the Workout instance with exercises
      Workout workout = Workout(
        id: workoutRow['id'],
        name: workoutRow['name'],
        userId: workoutRow['userId'],
        date: workoutRow['date'],
        markedColor: workoutRow['markedColor'],
        exercises: exercises, // Include exercises in the Workout object
      );

      return workout; // Return the populated Workout instance
    } catch (e, stackTrace) {
      logger.e('Error fetching workout: $e', stackTrace: stackTrace);
      throw Exception('Failed to fetch workout: $e');
    }
  }

  Future<ResponseData> editWorkout(
    Workout workoutToEdit,
    List<Exercise> exerciseListToEdit,
    int workoutId,
  ) async {
    try {
      // Start a transaction for atomic operations
      await _sqflite.transaction((txn) async {
        // Check if the workout exists
        final List<Map<String, dynamic>> workoutRows = await txn.query(
          'Workout',
          where: 'id = ?',
          whereArgs: [workoutId],
        );

        if (workoutRows.isEmpty) {
          throw Exception('Workout with ID $workoutId does not exist');
        }

        // Update the workout details
        await txn.update(
          'Workout',
          {
            'name': workoutToEdit.name,
            'date': workoutToEdit.date,
          },
          where: 'id = ?',
          whereArgs: [workoutId],
        );

        // Fetch the existing exercises for this workout
        final List<Map<String, dynamic>> existingExerciseRows = await txn.query(
          'Exercise',
          where: 'workoutId = ?',
          whereArgs: [workoutId],
        );

        final List<int> existingExerciseIds =
            existingExerciseRows.map((row) => row['id'] as int).toList();

        if (existingExerciseIds.length != exerciseListToEdit.length) {
          // Delete old exercises
          await txn.delete(
            'Exercise',
            where: 'workoutId = ?',
            whereArgs: [workoutId],
          );

          // Insert new exercises
          for (final exercise in exerciseListToEdit) {
            await txn.insert(
              'Exercise',
              {
                'name': exercise.name,
                'workoutId': workoutId,
                'kg': exercise.kg,
                'reps': exercise.rep,
                'sets': exercise.set,
              },
            );
          }
        } else {
          // Update existing exercises
          for (int i = 0; i < exerciseListToEdit.length; i++) {
            final updatedExercise = exerciseListToEdit[i];
            final exerciseId = existingExerciseIds[i];

            await txn.update(
              'Exercise',
              {
                'name': updatedExercise.name,
                'kg': updatedExercise.kg,
                'reps': updatedExercise.rep,
                'sets': updatedExercise.set,
              },
              where: 'id = ?',
              whereArgs: [exerciseId],
            );
          }
        }
      });

      return ResponseData(
        checksuccess: true,
        message: 'Workout was successfully edited',
      );
    } catch (e) {
      return ResponseData(
        checksuccess: false,
        message: 'Error when trying to edit workout: ${e.toString()}',
      );
    }
  }

  Future<ResponseData> deleteWorkout(Workout workout) async {
    try {
      // Start a transaction to ensure atomicity
      await _sqflite.transaction((txn) async {
        // Find the workout by userId and date
        final List<Map<String, dynamic>> workoutRows = await txn.query(
          'Workout',
          where: 'userId = ? AND date = ?',
          whereArgs: [workout.userId, workout.date],
        );

        if (workoutRows.isEmpty) {
          return ResponseData(
            checksuccess: false,
            message: 'Workout does not exist and cannot be deleted.',
          );
        }

        // Extract the workout ID (there should be only one match)
        final workoutId = workoutRows.first['id'];

        // Delete related exercises
        await txn.delete(
          'Exercise',
          where: 'workoutId = ?',
          whereArgs: [workoutId],
        );

        // Delete the workout itself
        await txn.delete(
          'Workout',
          where: 'id = ?',
          whereArgs: [workoutId],
        );
      });

      return ResponseData(
        checksuccess: true,
        message: 'Workout was successfully deleted.',
      );
    } catch (e) {
      return ResponseData(
        checksuccess: false,
        message: 'Error when trying to delete workout: ${e.toString()}',
      );
    }
  }

  String capitalizeFirstLetter(String str) {
    if (str.isEmpty) return str; // Check for empty string
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }
}
