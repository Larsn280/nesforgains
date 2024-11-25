import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/screens/dishScreens/display_dishes_screen.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/dish_service.dart';
import 'package:nesforgains/service/nutrition_service.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:nesforgains/widgets/custom_snackbar.dart';
import 'package:sqflite/sqflite.dart';

class NutritionScreen extends StatefulWidget {
  final Database sqflite;

  const NutritionScreen({super.key, required this.sqflite});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _allDishNames = [];
  List<String> _filteredDishes = [];
  int calories = 0;
  int proteine = 0;
  int carbohydrates = 0;
  int fat = 0;

  late DishService dishService;
  late NutritionService nutritionService;

  @override
  void initState() {
    super.initState();
    dishService = DishService(widget.sqflite);
    nutritionService = NutritionService(widget.sqflite);
    _fetchAllDishNames();
    _fetchDailyIntake();
    _searchController.addListener(_filterDishes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDishes);
    _searchController.dispose();
    super.dispose();
  }

  void _fetchAllDishNames() async {
    try {
      final dishList =
          await dishService.fetchAllDishNamesById(AuthProvider.of(context).id);
      setState(() {
        _allDishNames = dishList;
      });
    } catch (e) {
      logger.e('Error fetching', error: e);
    }
  }

  void _fetchDailyIntake() async {
    try {
      final intake = await nutritionService
          .fetchDailyNutritionById(AuthProvider.of(context).id);
      setState(() {
        calories = intake.calories;
        proteine = intake.protein;
        carbohydrates = intake.carbohydrates;
        fat = intake.fat;
      });
    } catch (e) {
      logger.e('Error fetching intake', error: e);
    }
  }

  void _postDailyDish(dish) async {
    try {
      final response = await nutritionService.postDailyDish(
          dish, AuthProvider.of(context).id);
      if (response.checksuccess == true) {
        _searchController.clear();
        _fetchDailyIntake();
      }
    } catch (e) {
      logger.e('Error posting', error: e);
    }
  }

  void _putDailyDish(dish) async {
    try {
      final response = await nutritionService.putDailyDish(
          dish, AuthProvider.of(context).id);
      if (response.checksuccess == true) {
        _searchController.clear();
        _fetchDailyIntake();
      }
    } catch (e) {
      logger.e('Error puting:', error: e);
    }
  }

  void _filterDishes() {
    try {
      final query = _searchController.text.toLowerCase();
      setState(() {
        if (query.isNotEmpty) {
          _filteredDishes = _allDishNames.where((dish) {
            return dish.toLowerCase().startsWith(query);
          }).toList();

          // Check if the query matches any dish exactly
          if (_filteredDishes.length == 1 &&
              _filteredDishes[0].toLowerCase() == query) {
            _filteredDishes.clear();
          }
        } else {
          _filteredDishes.clear();
        }
      });
    } catch (e) {
      logger.e('Error filtering', error: e);
    }
  }

  void _setsearchcontollertext(String dish) {
    setState(() {
      _searchController.text = dish;
    });
  }

  void _navigatetodishlist() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayDishesScreen(
          sqflite: widget.sqflite,
        ),
      ),
    );
    if (result == true) {
      _fetchAllDishNames();
    }
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
              fit: BoxFit.cover),
        ),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  const CustomAppbar(
                    title: 'Nutrition Screen',
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  CustomCards.buildFormCard(
                    context: context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15.0),
                        Text('Total calories today: $calories g',
                            style: AppConstants.subheadingStyle),
                        const SizedBox(height: 10),
                        Text('Protein: $proteine g',
                            style: AppConstants.subheadingStyle),
                        Text('Carbohydrates: $carbohydrates g',
                            style: AppConstants.subheadingStyle),
                        Text('Fat: $fat g',
                            style: AppConstants.subheadingStyle),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Enter dish',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 6.0),
                          ),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 45.0,
                              height: 45.0,
                              child: FloatingActionButton(
                                heroTag: 'floatButtonOne',
                                onPressed: () {
                                  // Define the action to be taken when the button is pressed
                                  _postDailyDish(_searchController.text);
                                },
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.black,
                                child: const Icon(Icons.add),
                              ),
                            ),
                            SizedBox(
                              width: 45.0,
                              height: 45.0,
                              child: FloatingActionButton(
                                heroTag: 'floatButtonTwo',
                                onPressed: () {
                                  _putDailyDish(_searchController.text);
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.black,
                                child: const Icon(Icons.remove),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  CustomButtons.buildElevatedFunctionButton(
                      context: context,
                      onPressed: () {
                        _navigatetodishlist();
                      },
                      text: 'Dishlist'),
                  CustomButtons.buildElevatedFunctionButton(
                      context: context,
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      text: 'Home')
                ],
              ),
              if (_filteredDishes.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 320, // Adjust this value based on your layout
                  child:
                      _searchdropdown(_filteredDishes, _setsearchcontollertext),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _searchdropdown(List<String> items, void Function(String) ontap) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 32.0),
    constraints: const BoxConstraints(maxHeight: 200),
    color: Colors.white.withOpacity(0.9),
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items.map((String item) {
          return InkWell(
            onTap: () {
              ontap(item);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
              color: const Color.fromARGB(255, 17, 17, 17),
              child: Text(item,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0)),
            ),
          );
        }).toList(),
      ),
    ),
  );
}
