import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/exercise.dart';
import 'package:nesforgains/models/workout.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/workout_service.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';
import 'package:nesforgains/widgets/custom_back_navigation.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:nesforgains/widgets/custom_snackbar.dart';
import 'package:sqflite/sqflite.dart';

class EditWorkoutScreen extends StatefulWidget {
  final Database sqflite;
  final Workout workout; // Pass the log to edit

  const EditWorkoutScreen(
      {super.key, required this.sqflite, required this.workout});

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  late WorkoutService workoutService;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _workoutController;
  late TextEditingController _exerciseController;
  late TextEditingController _dateController;
  late TextEditingController _repsController;
  late TextEditingController _setsController;
  late TextEditingController _kgController;

  @override
  void initState() {
    super.initState();
    workoutService = WorkoutService(widget.sqflite);
    _workoutController =
        TextEditingController(text: widget.workout.name.toString());
    _exerciseController = TextEditingController();
    _dateController =
        TextEditingController(text: widget.workout.date.toString());
    _repsController = TextEditingController();
    _setsController = TextEditingController();
    _kgController = TextEditingController();
    _sortIsarLinks(widget.workout);
  }

  @override
  void dispose() {
    _workoutController.dispose();
    _exerciseController.dispose();
    _dateController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    _kgController.dispose();
    super.dispose();
  }

  void _sortIsarLinks(Workout workout) {
    final exerciseList = workout.exercises!.map((e) => e.name).toList();
    final repList = workout.exercises!.map((e) => e.rep).toList();
    final setList = workout.exercises!.map((e) => e.set).toList();
    final kgList = workout.exercises!.map((e) => e.kg).toList();

    StringBuffer allExercisesBuffer = StringBuffer();
    StringBuffer allRepsBuffer = StringBuffer();
    StringBuffer allSetsBuffer = StringBuffer();
    StringBuffer allWeigthsBuffer = StringBuffer();

    allExercisesBuffer.writeAll(exerciseList, ', ');
    allRepsBuffer.writeAll(repList, ', ');
    allSetsBuffer.writeAll(setList, ', ');
    allWeigthsBuffer.writeAll(kgList, ', ');

    _exerciseController.text = allExercisesBuffer.toString();
    _repsController.text = allRepsBuffer.toString();
    _setsController.text = allSetsBuffer.toString();
    _kgController.text = allWeigthsBuffer.toString();
  }

  Future<void> _handleEditWorkout() async {
    try {
      final List<Exercise> exerciseList = [];
      final int workoutId = widget.workout.id;
      if (_formKey.currentState!.validate()) {
        final workoutValue = _workoutController.text.toString();
        final splitExerciseList = _exerciseController.text.split(',');
        final splitKgList = _kgController.text.split(',');
        final splitRepList = _repsController.text.split(',');
        final splitSetList = _setsController.text.split(',');

        // Validate matching lengths of lists
        if (splitExerciseList.length != splitKgList.length ||
            splitExerciseList.length != splitRepList.length ||
            splitExerciseList.length != splitSetList.length) {
          CustomSnackbar.showSnackBar(
              message:
                  'Please ensure all fields have the same number of entries.');
          return;
        }

        final userIdValue = AuthProvider.of(context).id;

        final workout = Workout(
            id: widget.workout.id,
            name: workoutValue,
            date: _dateController.text.toString(),
            userId: userIdValue);

        for (int i = 0; i < splitExerciseList.length; i++) {
          final exercise = Exercise(
            name: splitExerciseList[i].trim(),
            kg: double.tryParse(splitKgList[i].trim()),
            rep: int.tryParse(splitRepList[i].trim()),
            set: int.tryParse(splitSetList[i].trim()),
          );
          exerciseList.add(exercise);
        }

        final response =
            await workoutService.editWorkout(workout, exerciseList, workoutId);

        if (mounted) {
          Navigator.pop(context, true);
        }
        CustomSnackbar.showSnackBar(message: response.message);
      }
    } catch (e) {
      logger.e('Error editing workout:', error: e);
      CustomSnackbar.showSnackBar(
          message:
              'An error occurred while editing the workout. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackNavigation.customBackNavigation(
      context: context,
      child: Scaffold(
        body: SizedBox.expand(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppConstants.appbackgroundimage),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const CustomAppbar(
                    title: 'Edit Workout',
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  CustomCards.buildFormCard(
                    context: context,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 16.0),
                          _buildFormTextFormField(
                              'Workout (eg: Chest, Legs, Bak)',
                              _workoutController),
                          _buildFormTextFormField(
                              'Exercises eg: (Benchpress, comma separated)',
                              _exerciseController),
                          _buildFormTextFormField(
                              'Date (YYYY-MM-DD)', _dateController),
                          _buildFormTextFormField(
                              '(Reps, comma separated)', _repsController),
                          _buildFormTextFormField(
                              '(Sets, comma separated)', _setsController),
                          _buildFormTextFormField(
                              '(Kg, comma separated)', _kgController),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  CustomButtons.buildElevatedFunctionButton(
                      context: context,
                      onPressed: _handleEditWorkout,
                      text: 'Save'),
                  CustomButtons.buildElevatedFunctionButton(
                      context: context,
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      text: 'Back'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormTextFormField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (isNumeric && double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}
