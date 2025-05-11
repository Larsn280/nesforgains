import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/workout_data.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/workout_service.dart';
import 'package:nesforgains/widgets/custom_app_container.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:nesforgains/widgets/custom_snackbar.dart';
import 'package:sqflite/sqflite.dart';

class TrainingProgramScreen extends StatefulWidget {
  final Database sqflite;
  const TrainingProgramScreen(
      {super.key, required this.sqflite}); //TODO Ta bort sqflite.

  @override
  State<TrainingProgramScreen> createState() => _TrainingProgramScreenState();
}

class _TrainingProgramScreenState extends State<TrainingProgramScreen> {
  late Future<List<WorkoutData>> _futuretrainingPrograms; //TODO Byt ut.
  late WorkoutService workoutService; //TODO Byt ut.

  @override
  void initState() {
    super.initState();
    workoutService = WorkoutService(widget.sqflite); //TODO Byt ut.
    _futuretrainingPrograms = _fetchAllWorkouts(); //TODO Byt ut.
  }

  Future<List<WorkoutData>> _fetchAllWorkouts() async {
    try {
      final userId = AuthProvider.of(context).loggedInUser.id;
      final response = await workoutService.fetchAllWorkouts(userId);
      return response;
    } catch (e) {
      logger.e('Error fetching workouts', error: e);
      CustomSnackbar.showSnackBar(
          message:
              'An error occurred while fetching the workouts. Please try again.');

      return [];
    }
  } //TODO Byt ut.

  @override
  Widget build(BuildContext context) {
    return CustomAppContainer(
        titleText: 'Träningsprogram',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 40.0,
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 600),
              child: FutureBuilder<List<WorkoutData>>(
                future: _futuretrainingPrograms,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildProgramList([], 'Indicator');
                  } else if (snapshot.hasError) {
                    return _buildProgramList([], 'Error loading programs');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildProgramList([], 'Inga program tillgängliga');
                  }

                  final programs = snapshot.data!;
                  return _buildProgramList(programs, '');
                },
              ), //TODO Byt WorkoutData.
            ),
          ],
        ));
  }

  Widget _buildProgramList(List<WorkoutData> programs, String message) {
    return CustomCards.buildListCard(
      context: context,
      child: Column(
        children: [
          Expanded(
              child: programs.isNotEmpty
                  ? ListView.builder(
                      itemCount: programs.length,
                      itemBuilder: (context, index) {
                        final program = programs[index];
                        return Text(
                            program.name); //TODO Byt ut mot vad som ska visas.
                      },
                    )
                  : Center(
                      child: message.startsWith('Indicator')
                          ? CircularProgressIndicator(
                              color: AppConstants.primaryTextColor,
                            )
                          : Text(message),
                    ))
        ],
      ),
    );
  } //TODO Byt ut WordoutData.
}
