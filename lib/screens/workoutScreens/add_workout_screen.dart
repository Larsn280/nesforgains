import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/exercise.dart';
import 'package:nesforgains/models/selected_exercise.dart';
import 'package:nesforgains/models/workout.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/workout_service.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';
import 'package:nesforgains/widgets/custom_back_navigation.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:nesforgains/widgets/custom_dropdownlist.dart';
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

  DateTime? _selectedDate;
  late String responseMessage;

  late WorkoutService workoutService;

  late List<SelectedExercise> selectedExercises;

  final List<String> _workoutList = ['Chest', 'Legs', 'Bak'];

  final List<String> _exerciseList = ['Benchpress', 'Squats', 'Deadlift'];

  @override
  void initState() {
    super.initState();
    workoutService = WorkoutService(widget.sqflite);
  }

  @override
  void dispose() {
    _workoutController.dispose();
    super.dispose();
  }

  void _saveTrainingData() async {
    try {
      final List<Exercise> exerciseList = [];
      if (_formKey.currentState!.validate() && _selectedDate != null) {
        final workoutValue = _workoutController.text.toString();

        final userIdValue = AuthProvider.of(context).id;

        final workout = Workout(
            id: 0,
            name: workoutValue,
            date: _selectedDate.toString(),
            userId: userIdValue);

        for (var exercise in selectedExercises) {
          final newExercise = Exercise(
            name: exercise.name.trim(),
            kg: exercise.weight,
            rep: int.tryParse(exercise.reps.trim()),
            set: int.tryParse(exercise.sets.trim()),
          );
          exerciseList.add(newExercise);
        }

        final response = await workoutService.addWorkout(workout, exerciseList);

        setState(() {
          if (response.checksuccess) {
            _workoutController.clear();
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
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),
                            child: Row(
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
                                        style: const TextStyle(
                                            color: Colors.white),
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
                          ),
                          CustomDropdownlist(
                            defaultText: 'Select Workout Type',
                            controller: _workoutController,
                            selectList: _workoutList,
                            multiselectList: false,
                          ),
                          CustomDropdownlist(
                            defaultText: 'Select Exercise',
                            exerciseList: selectedExercises,
                            selectList: _exerciseList,
                            multiselectList: true,
                          ),
                          // _buildFormTextFormField(
                          //     controller: _workoutController,
                          //     lable: 'Workout (eg: Chest, Legs, Bak)',
                          //     validatorText:
                          //         'Please enter workout eg: Legs...'),

                          // _buildFormTextFormField(
                          //     controller: _exerciseController,
                          //     lable:
                          //         'Exercises eg: (Benchpress, comma separated)',
                          //     validatorText:
                          //         'Please enter exercise eg: Benchpress...'),
                          // _buildFormTextFormField(
                          //     controller: _weightController,
                          //     lable: '(Kg, comma separated)',
                          //     validatorText: 'Please enter weight in kg...'),

                          // _buildFormTextFormField(
                          //     controller: _repsController,
                          //     lable: 'Reps (comma separated)',
                          //     validatorText:
                          //         'Please enter reps (comma separated)...'),

                          // _buildFormTextFormField(
                          //     controller: _setsController,
                          //     lable: 'Sets (comma separated)',
                          //     validatorText:
                          //         'Please enter sets (comma separated)'),
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
    required String defaultText,
    required List<String> selectList,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.black54, // Background color
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        border: Border.all(color: Colors.white, width: 2.0), // Border color
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.text.isEmpty ? null : controller.text,
          hint: Text(
            controller.text.isEmpty ? defaultText : controller.text,
            style: const TextStyle(color: Colors.white),
          ),
          dropdownColor: Colors.black87, // Dropdown background color
          icon: controller.text.isEmpty
              ? const Icon(Icons.arrow_drop_down, color: Colors.white)
              : const Icon(Icons.check_circle, color: Colors.green),
          style: const TextStyle(color: Colors.white),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.text = newValue; // Update the controller text
            }
          },
          items: selectList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
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
