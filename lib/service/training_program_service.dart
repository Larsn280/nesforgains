import 'dart:convert';

import 'package:nesforgains/models/response_data.dart';
import 'package:nesforgains/models/training_program/training_program.dart';
import 'package:http/http.dart' as http;

//TODO Byt till Rätt connectionString i .env och här.
class TrainingProgramService {
  final String baseUrl;

  // Constructor to initialize the base URL for the API
  TrainingProgramService({this.baseUrl = 'https://api.example.com'});

  Future<List<TrainingProgram>> fetchTrainingPrograms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/training_programs'), // Adjust the endpoint
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) => TrainingProgram.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to fetch training programs. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching training programs: $e');
    }
  }

  // Add a new training program
  Future<ResponseData> addTrainingProgram(TrainingProgram program) async {
    try {
      // Basic validation for the program (check if title and description are empty)
      if (program.title.isEmpty || program.description.isEmpty) {
        return ResponseData(
          checksuccess: false,
          message: 'Title and description are required.',
        );
      }

      // Prepare the data for the POST request
      final Map<String, dynamic> programData = {
        'title': program.title,
        'description': program.description,
        'durationWeeks': program.durationWeeks,
        'sessionsPerWeek': program.sessionsPerWeek,
        'difficulty': program.difficulty,
        'workouts': program.workouts
            .map((day) => {
                  'day': day.day,
                  'exercises': day.exercises
                      .map((exercise) => {
                            'name': exercise.name,
                            'reps': exercise.reps,
                            'sets': exercise.sets,
                            'weight': exercise.weight,
                          })
                      .toList(),
                })
            .toList(),
      };

      // Make the POST request to the API
      final response = await http.post(
        Uri.parse('$baseUrl/training_programs'), // Adjust the endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode(programData),
      );

      // Check if the response was successful (status code 201: Created)
      if (response.statusCode == 201) {
        return ResponseData(
          checksuccess: true,
          message: 'Training program added successfully!',
        );
      } else {
        // If not successful, return the response message or code
        return ResponseData(
          checksuccess: false,
          message:
              'Failed to add training program. Server responded with ${response.statusCode}.',
        );
      }
    } catch (e) {
      // Catch any errors (e.g., network issues, exceptions)
      return ResponseData(
        checksuccess: false,
        message:
            'An error occurred while adding the training program: ${e.toString()}',
      );
    }
  }
}
