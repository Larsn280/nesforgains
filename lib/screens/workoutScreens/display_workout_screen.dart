import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/checkbox_item.dart';
import 'package:nesforgains/models/workout.dart';
import 'package:nesforgains/screens/workoutScreens/add_workout_screen.dart';
import 'package:nesforgains/screens/workoutScreens/display_workout_details_screen.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/scoreboard_service.dart';
import 'package:nesforgains/service/workout_service.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:nesforgains/widgets/custom_checkboxes.dart';
import 'package:nesforgains/widgets/custom_snackbar.dart';
import 'package:sqflite/sqflite.dart';

class DisplayWorkoutScreen extends StatefulWidget {
  final Database sqflite;

  const DisplayWorkoutScreen({super.key, required this.sqflite});

  @override
  State<DisplayWorkoutScreen> createState() => _DisplayWorkScreenState();
}

class _DisplayWorkScreenState extends State<DisplayWorkoutScreen> {
  static const double sizedBoxHeight = 18.0;
  late WorkoutService workoutService;
  late Future<List<Workout>> _futureWorkouts;
  List<CheckboxItem> isFirstCheckedList = [];
  List<CheckboxItem> isSecondCheckedList = [];
  late ScoreboardService scoreboardService;

  @override
  void initState() {
    super.initState();
    workoutService = WorkoutService(widget.sqflite);
    scoreboardService = ScoreboardService(widget.sqflite);
    _futureWorkouts = _fetchAllWorkouts();
    _initializeIsCheckedList();
  }

  void _initializeIsCheckedList() async {
    final workoutList = await _fetchAllWorkouts();
    for (var workout in workoutList) {
      if (workout.markedColor == 'green') {
        final firstItem = CheckboxItem(id: workout.id, isChecked: true);
        isFirstCheckedList.add(firstItem);
      } else if (workout.markedColor == 'red') {
        final secondItem = CheckboxItem(id: workout.id + 1, isChecked: true);
        isSecondCheckedList.add(secondItem);
      } else {
        final firstItem = CheckboxItem(id: workout.id);
        final secondItem = CheckboxItem(id: workout.id + 1);
        isFirstCheckedList.add(firstItem);
        isSecondCheckedList.add(secondItem);
      }
    }
  }

  bool setFirstIsChecked(int id) {
    for (var bool in isFirstCheckedList) {
      if (bool.id == id) {
        return bool.isChecked;
      }
    }
    return false;
  }

  bool setSecondIsChecked(int id) {
    for (var bool in isSecondCheckedList) {
      if (bool.id == id) {
        return bool.isChecked;
      }
    }
    return false;
  }

  Future<List<Workout>> _fetchAllWorkouts() async {
    try {
      final userId = AuthProvider.of(context).id;
      final response = await workoutService.fetchAllWorkouts(userId);
      return response;
    } catch (e) {
      logger.e('Error fetching workouts', error: e);
      CustomSnackbar.showSnackBar(
          message:
              'An error occurred while fetching the workouts. Please try again.');

      return [];
    }
  }

  void _navigateToWorkoutDetails(Workout workout) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayWorkoutDetailsScreen(
          workout: workout,
          sqflite: widget.sqflite,
        ),
      ),
    );
    if (result == true) {
      setState(() {
        _futureWorkouts = _fetchAllWorkouts();
      });
    }
  }

  void _navigateToAddWorkout() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWorkoutScreen(
          sqflite: widget.sqflite,
        ),
      ),
    );
    if (result == true) {
      await scoreboardService.syncS3ToDatabase();
      setState(() {
        _futureWorkouts = _fetchAllWorkouts();
        _initializeIsCheckedList();
      });
    }
  }

  void toggleFirstCheckBox(int id) async {
    for (var bool in isFirstCheckedList) {
      if (bool.id == id) {
        setState(() {
          bool.isChecked = !bool.isChecked;
        });

        try {
          // Update the markedColor in the database
          await widget.sqflite.update(
            'Workout',
            {'markedColor': bool.isChecked ? 'green' : null}, // Update color
            where: 'id = ?',
            whereArgs: [id],
          );
        } catch (e) {
          logger.e('Error updating markedColor: $e');
        }
      }
    }

    setState(() {
      _futureWorkouts = _fetchAllWorkouts();
    });
  }

  void toggleSecondCheckBox(int id) async {
    for (var bool in isSecondCheckedList) {
      if (bool.id == id) {
        setState(() {
          bool.isChecked = !bool.isChecked;
        });

        try {
          // Update the markedColor in the database
          await widget.sqflite.update(
            'Workout',
            {'markedColor': bool.isChecked ? 'red' : null}, // Update color
            where: 'id = ?',
            whereArgs: [id - 1], // Adjusting ID as per original logic
          );
        } catch (e) {
          logger.e('Error updating markedColor for second checkbox: $e');
        }
      }
    }

    setState(() {
      _futureWorkouts = _fetchAllWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.appbackgroundimage),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomAppbar(
              title: 'Workouts',
            ),
            const SizedBox(
              height: 40.0,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<Workout>>(
                future: _futureWorkouts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildTrainingList([], 'Indicator');
                  } else if (snapshot.hasError) {
                    return _buildTrainingList([], 'Error loading logs');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildTrainingList([], 'No training logs available');
                  }

                  final logs = snapshot.data!;
                  return _buildTrainingList(logs, '');
                },
              ),
            ),
            const SizedBox(height: 8.0),
            CustomButtons.buildElevatedFunctionButton(
                context: context,
                onPressed: () {
                  _navigateToAddWorkout();
                },
                text: 'Add'),
            CustomButtons.buildElevatedFunctionButton(
                context: context,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                text: 'Home'),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingHeader(bool areAllWorkoutsMarked) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          _buildTrainingColumnHeader(
              title: 'Workout/Exercise', widthFactor: 0.60),
          !areAllWorkoutsMarked
              ? Flexible(
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTrainingColumnHeader(title: 'Pass'),
                    _buildTrainingColumnHeader(title: 'Fail'),
                  ],
                ))
              : const Flexible(child: Row())
        ],
      ),
    );
  }

  Widget _buildTrainingColumnHeader(
      {required String title, double? widthFactor}) {
    return widthFactor != null
        ? SizedBox(
            height: sizedBoxHeight,
            width: MediaQuery.of(context).size.width * widthFactor,
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        : SizedBox(
            height: sizedBoxHeight,
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)));
  }

  Widget _buildTrainingRow(Workout log) {
    Color color = Colors.black54;

    if (log.markedColor != null) {
      if (log.markedColor == 'green') {
        color = Colors.green;
      } else {
        color = Colors.red;
      }
    }

    return GestureDetector(
      onTap: () {
        _navigateToWorkoutDetails(log);
      },
      child: CustomCards.buildWorkoutListItemCard(
        color: color,
        context: context,
        child: log.exercises!.length == 1
            ? Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.exercises!.map((e) => e.name).join('')),
                        Text(log.date.toString()),
                      ],
                    ),
                  ),
                  _buildTrainingColumn(
                      text:
                          '${log.exercises!.map((e) => e.rep).join('')}x${log.exercises!.map((e) => e.set).join('')} : ${log.exercises!.map((e) => e.kg).join('')}kg',
                      widthFactor: 0.30),
                  Flexible(
                      child: log.markedColor == null
                          ? SizedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomCheckBoxes.buildCheckBox(
                                      context: context,
                                      isChecked: setFirstIsChecked(log.id),
                                      onToggle: () {
                                        toggleFirstCheckBox(log.id);
                                      },
                                      icon: Icons.radio_button_checked,
                                      color: Colors.green),
                                  CustomCheckBoxes.buildCheckBox(
                                      context: context,
                                      isChecked: setSecondIsChecked(log.id + 1),
                                      onToggle: () {
                                        toggleSecondCheckBox(log.id + 1);
                                      },
                                      icon: Icons.radio_button_unchecked,
                                      color: Colors.red)
                                ],
                              ),
                            )
                          : const SizedBox()),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.name),
                        Text(log.date.toString()),
                      ],
                    ),
                  ),
                  Flexible(
                    child: log.markedColor == null
                        ? SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CustomCheckBoxes.buildCheckBox(
                                    context: context,
                                    isChecked: setFirstIsChecked(log.id),
                                    onToggle: () {
                                      toggleFirstCheckBox(log.id);
                                    },
                                    icon: Icons.radio_button_checked,
                                    color: Colors.green),
                                CustomCheckBoxes.buildCheckBox(
                                    context: context,
                                    isChecked: setSecondIsChecked(log.id + 1),
                                    onToggle: () {
                                      toggleSecondCheckBox(log.id + 1);
                                    },
                                    icon: Icons.radio_button_unchecked,
                                    color: Colors.red)
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTrainingColumn({required String text, double? widthFactor}) {
    return widthFactor != null
        ? SizedBox(
            height: sizedBoxHeight,
            width: MediaQuery.of(context).size.width * widthFactor,
            child: Text(text),
          )
        : SizedBox(
            height: sizedBoxHeight,
            child: Text(text),
          );
  }

  Widget _buildTrainingList(List<Workout> logs, String message) {
    final areAllWorkoutsMarked =
        logs.isNotEmpty && logs.every((log) => log.markedColor != null);
    return CustomCards.buildListCard(
      context: context,
      child: Column(
        children: [
          _buildTrainingHeader(areAllWorkoutsMarked),
          const Divider(),
          Expanded(
            child: logs.isNotEmpty
                ? ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return _buildTrainingRow(log);
                    },
                  )
                : Center(
                    child: message.startsWith('Indicator')
                        ? CircularProgressIndicator(
                            color: AppConstants.primaryTextColor,
                          )
                        : Text(message),
                  ),
          )
        ],
      ),
    );
  }
}
