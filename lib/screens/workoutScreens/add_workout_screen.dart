import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

class AddWorkoutScreen extends StatefulWidget {
  final Database sqflite;

  const AddWorkoutScreen({super.key, required this.sqflite});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreen();
}

class _AddWorkoutScreen extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workoutController = TextEditingController();
  final _exerciseController = TextEditingController();
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _setsController = TextEditingController();
  DateTime? _selectedDate;
  late String responseMessage;

  late WorkoutService workoutService;

  final List<String> _workoutList = ['Chest', 'Legs', 'Back'];

  @override
  void initState() {
    super.initState();
    workoutService = WorkoutService(widget.sqflite);
  }

  @override
  void dispose() {
    _workoutController.dispose();
    _exerciseController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    super.dispose();
  }

  void _saveTrainingData() async {
    try {
      final List<Exercise> exerciseList = [];
      if (_formKey.currentState!.validate() && _selectedDate != null) {
        final workoutValue = _workoutController.text.toString();
        final splitExerciseList = _exerciseController.text.split(',');
        final splitKgList = _weightController.text.split(',');
        final splitRepList = _repsController.text.split(',');
        final splitSetList = _setsController.text.split(',');

        // Validate matching lengths of lists
        if (splitExerciseList.length != splitKgList.length ||
            splitExerciseList.length != splitRepList.length ||
            splitExerciseList.length != splitSetList.length) {
          setState(() {
            responseMessage =
                'Please ensure all fields have the same number of entries.';
          });
          CustomSnackbar.showSnackBar(message: responseMessage);
          return;
        }

        final userIdValue = AuthProvider.of(context).id;

        final workout = Workout(
            id: 0,
            name: workoutValue,
            date: _selectedDate.toString(),
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

        final response = await workoutService.addWorkout(workout, exerciseList);

        setState(() {
          if (response.checksuccess) {
            _workoutController.clear();
            _exerciseController.clear();
            _weightController.clear();
            _repsController.clear();
            _setsController.clear();
            _selectedDate = null;
          }
          responseMessage = response.message;
          if (mounted) {
            Navigator.pop(context, true);
          }
        });

        CustomSnackbar.showSnackBar(message: responseMessage);
      } else {
        setState(() {
          responseMessage = 'Please fill in all fields';
        });

        CustomSnackbar.showSnackBar(message: responseMessage);
      }
    } catch (e) {
      logger.e('Error adding workout', error: e);
      CustomSnackbar.showSnackBar(
          message:
              'An error occurred while adding the workout. Please try again.');
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
                  fit: BoxFit.cover),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const CustomAppbar(
                    title: 'Log Workout',
                  ),
                  const SizedBox(height: 40.0),
                  CustomCards.buildFormCard(
                    context: context,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16.0),
                          // Date Picker
                          Row(
                            children: [
                              // Text and Date Picker Icon are grouped together
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedDate == null
                                          ? 'Select Date'
                                          : DateFormat('y-MMM-d')
                                              .format(_selectedDate!),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.calendar_today,
                                          color: Colors.white),
                                      onPressed: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2101),
                                        );
                                        if (pickedDate != null) {
                                          setState(() {
                                            _selectedDate = pickedDate;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              // Checkmark Icon, visible only when a date is selected
                              if (_selectedDate != null)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green, // Green checkmark
                                ),
                            ],
                          ),
                          _buildFormDropdownList(
                              controller: _workoutController,
                              defultText: 'Select Workout Type',
                              selectList: _workoutList),

                          // _buildFormTextFormField(
                          //     controller: _workoutController,
                          //     lable: 'Workout (eg: Chest, Legs, Bak)',
                          //     validatorText:
                          //         'Please enter workout eg: Legs...'),

                          _buildFormTextFormField(
                              controller: _exerciseController,
                              lable:
                                  'Exercises eg: (Benchpress, comma separated)',
                              validatorText:
                                  'Please enter exercise eg: Benchpress...'),
                          _buildFormTextFormField(
                              controller: _weightController,
                              lable: '(Kg, comma separated)',
                              validatorText: 'Please enter weight in kg...'),

                          _buildFormTextFormField(
                              controller: _repsController,
                              lable: 'Reps (comma separated)',
                              validatorText:
                                  'Please enter reps (comma separated)...'),

                          _buildFormTextFormField(
                              controller: _setsController,
                              lable: 'Sets (comma separated)',
                              validatorText:
                                  'Please enter sets (comma separated)'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8.0),
                  // Submit button
                  CustomButtons.buildElevatedFunctionButton(
                      context: context,
                      onPressed: _saveTrainingData,
                      text: 'Save Workout'),
                  CustomButtons.buildElevatedFunctionButton(
                      context: context,
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      text: 'Back')
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormDropdownList({
    required TextEditingController controller,
    required String defultText,
    required List<String> selectList,
  }) {
    return Row(
      children: [
        Text(
          _workoutController.text.isEmpty
              ? defultText
              : _workoutController.text,
          style: const TextStyle(color: Colors.white),
        ),
        const Spacer(),
        controller.text.isEmpty
            ? IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              )
            : const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
      ],
    );
  }

  Widget _buildFormTextFormField({
    required TextEditingController controller,
    required String lable,
    required String validatorText,
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: lable,
        filled: true,
        fillColor: Colors.black54,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        if (isNumeric && int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }
}
