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
import 'package:nesforgains/widgets/custom_dropdownlistnew.dart';
import 'package:nesforgains/widgets/custom_search_dropdownlist.dart';
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
  final _repsController = TextEditingController();
  final _setsController = TextEditingController();
  final _weigthController = TextEditingController();
  String? _workoutError;
  String? _exerciseError;
  String? _repsError;
  String? _setsError;
  String? _weightError;

  DateTime? _selectedDate;
  late String responseMessage;

  late WorkoutService workoutService;

  final List<SelectedExercise> selectedExercises = [];
  SelectedExercise selectedExercise =
      SelectedExercise(name: '', reps: '', sets: '', weight: 0);

  final List<String> _workoutList = [
    'Chest',
    'Legs',
    'Bak',
  ];

  final List<String> _exerciseList = [
    'Benchpress',
    'Squats',
    'Deadlift',
  ];
  final Map<String, Map<String, String>> completeexercise = {};
  final List<SelectedExercise> allcompleteexercise = [];
  final List<String> _selectsvalues =
      List.generate(20, (index) => (index + 1).toString());

  final bool closedropdowns = false;

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

  bool _validateExerciseInput() {
    setState(() {
      _repsError = _repsController.text.isEmpty
          ? 'Please select the number of reps.'
          : null;

      _setsError = _setsController.text.isEmpty
          ? 'Please select the number of sets.'
          : null;

      _weightError = _weigthController.text.isEmpty
          ? 'Please enter a valid weight.'
          : null;
    });

    // Return true if all fields are valid
    return _repsError == null && _setsError == null && _weightError == null;
  }

  bool _validateWorkoutInput() {
    setState(() {
      _workoutError =
          _workoutController.text.isEmpty ? 'Please input workout.' : null;

      _exerciseError =
          selectedExercises.isEmpty ? 'Please input exercise.' : null;
    });

    // Return true if all fields are valid
    return _weightError == null && _exerciseError == null;
  }

  void _saveTrainingData() async {
    try {
      final List<Exercise> exerciseList = [];
      if (_formKey.currentState!.validate() &&
          _selectedDate != null &&
          _validateWorkoutInput() == true) {
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
        body: GestureDetector(
          onTap: () {
            setState(() {});
          },
          child: SizedBox.expand(
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
                      title: 'Logga Träningspass',
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
                              padding: const EdgeInsets.symmetric(
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
                                              ? 'Välj datum'
                                              : DateFormat(
                                                      'yyyy-MM-dd', 'sv_SE')
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
                                              locale: const Locale('sv',
                                                  'SE'), // Ställ in språk till svenska
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
                            CustomSearchDropdownList(
                              isNumeric: false,
                              errorMessage: _workoutError,
                              controller: _workoutController,
                              hasBorder: true,
                              defaultText: 'Träningspass',
                              listItems: _workoutList,
                              onErrorChanged: (newError) {
                                setState(() {
                                  _workoutError = newError;
                                });
                              },
                            ),
                            if (_workoutError != null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  _workoutError!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12.0),
                                ),
                              ),
                            if (selectedExercises.isNotEmpty)
                              Column(
                                children: [
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 4.0,
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    child: Wrap(
                                      spacing:
                                          8.0, // Horizontal spacing between items
                                      runSpacing:
                                          8.0, // Vertical spacing between rows
                                      alignment: WrapAlignment.center,
                                      children:
                                          selectedExercises.map((exercise) {
                                        return SizedBox(
                                          child: Container(
                                            padding: const EdgeInsets.all(4.0),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize
                                                  .min, // Shrink the Row to fit content
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    exercise.name,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          12.0, // Compact font size
                                                    ),
                                                    overflow: TextOverflow
                                                        .ellipsis, // Truncate long text
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width:
                                                        2.0), // Minimal space between text and icon
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedExercises
                                                          .remove(exercise);
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.cancel,
                                                    color: Colors.white,
                                                    size:
                                                        12.0, // Compact icon size
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(
                              height: 10.0,
                            ),
                            _exerciseController.text.isEmpty &&
                                    _exerciseController.text.length < 2
                                ? Column(
                                    children: [
                                      CustomSearchDropdownList(
                                        isNumeric: false,
                                        errorMessage: _exerciseError,
                                        hasBorder: true,
                                        controller: _exerciseController,
                                        defaultText: 'Övning',
                                        listItems: _exerciseList,
                                        onErrorChanged: (newError) {
                                          setState(() {
                                            _exerciseError = newError;
                                          });
                                        },
                                      ),
                                      if (_exerciseError != null)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Text(
                                            _exerciseError!,
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 12.0),
                                          ),
                                        ),
                                    ],
                                  )
                                : Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 20.0),
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        border: Border.all(
                                            color: Colors.white, width: 1.0),
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Avbryt',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.transparent),
                                            ),
                                            Text(
                                              'Input for ${_exerciseController.text}',
                                              style: const TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _exerciseController.clear();
                                                  _setsController.clear();
                                                  _repsController.clear();
                                                  _weigthController.clear();
                                                });
                                              },
                                              child: const Text(
                                                'Avbryt',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 16.0,
                                        ),
                                        CustomDropdownlistnew(
                                            errormessage: _repsError,
                                            hasboarder: true,
                                            controller: _repsController,
                                            defaulttext: 'Välj Reps',
                                            listitems: _selectsvalues),
                                        const SizedBox(
                                          height: 5.0,
                                        ),
                                        CustomDropdownlistnew(
                                          errormessage: _setsError,
                                          hasboarder: true,
                                          controller: _setsController,
                                          defaulttext: 'Välj Sets',
                                          listitems: _selectsvalues,
                                        ),
                                        const SizedBox(
                                          height: 5.0,
                                        ),
                                        CustomSearchDropdownList(
                                          isNumeric: true,
                                          errorMessage: _weightError,
                                          hasBorder: true,
                                          controller: _weigthController,
                                          defaultText: 'Skriv vikt',
                                          listItems: const [],
                                          onErrorChanged: (newError) {
                                            setState(() {
                                              _weightError = newError;
                                            });
                                          },
                                        ),
                                        if (_weightError != null)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: Text(
                                              _weightError!,
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        CustomButtons.buildSmallElevatedButton(
                                          onPressed: () {
                                            if (_validateExerciseInput() ==
                                                true) {
                                              setState(() {
                                                // Create a new instance of SelectedExercise
                                                final newExercise =
                                                    SelectedExercise(
                                                  name:
                                                      _exerciseController.text,
                                                  reps: _repsController.text,
                                                  sets: _setsController.text,
                                                  weight: double.tryParse(
                                                          _weigthController
                                                              .text) ??
                                                      0,
                                                );

                                                // Add the new instance to the list
                                                selectedExercises
                                                    .add(newExercise);

                                                // Clear the input fields
                                                _exerciseController.clear();
                                                _repsController.clear();
                                                _setsController.clear();
                                                _weigthController.clear();
                                              });
                                            }
                                          },
                                          text: 'Lägg till',
                                          context: context,
                                        ),
                                      ],
                                    ),
                                  ),
                            const SizedBox(
                              height: 16.0,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8.0),
                    // Submit button
                    CustomButtons.buildElevatedFunctionButton(
                        context: context,
                        onPressed: _saveTrainingData,
                        text: 'Spara'),
                    CustomButtons.buildElevatedFunctionButton(
                        context: context,
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        text: 'Tillbaka')
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormMultiSelectDropdownList({required String defaultText}) {
    bool isDropdownShowing = false;

    return GestureDetector(
        onTap: () => {
              setState(() {
                isDropdownShowing = !isDropdownShowing;
              }),
            },
        child: isDropdownShowing == false
            ? Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: const BoxDecoration(color: Colors.black54),
                child: Text(defaultText),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: const BoxDecoration(color: Colors.black54),
                child: const Text(' Is showing'),
              ));
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
