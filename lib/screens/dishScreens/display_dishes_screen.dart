import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/dish.dart';
import 'package:nesforgains/screens/dishScreens/add_dish_screen.dart';
import 'package:nesforgains/screens/dishScreens/edit_dish_screen.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/dish_service.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:nesforgains/widgets/custom_snackbar.dart';
import 'package:sqflite/sqflite.dart';

class DisplayDishesScreen extends StatefulWidget {
  final Database sqflite;

  const DisplayDishesScreen({super.key, required this.sqflite});

  @override
  State<DisplayDishesScreen> createState() => _DisplayDishesScreenState();
}

class _DisplayDishesScreenState extends State<DisplayDishesScreen> {
  static const double sizedBoxHeight = 18.0;
  late DishService nutritionService;

  @override
  void initState() {
    super.initState();
    nutritionService = DishService(widget.sqflite);
  }

  Future<List<Dish>> _handlefetchAllDishes() async {
    try {
      final response = await nutritionService
          .fetchAllDishesById(AuthProvider.of(context).id);
      return response;
    } catch (e) {
      logger.e('Error fetching dishes', error: e);
      return [];
    }
  }

  void _handleDeleteDish(String name, int userId) async {
    try {
      await nutritionService.deleteDish(name, userId);
      // Triggar en rebuild av widget trädet.
      setState(() {});
    } catch (e) {
      logger.e('Error deleting dish', error: e);
    }
  }

  void _navigateToEditDish(Dish dish) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditDishScreen(
            dish: dish,
            sqflite: widget.sqflite,
          ),
        ),
      );
      if (result == true) {
        setState(() {
          _handlefetchAllDishes();
        });
      }
    } catch (e) {
      logger.e('Error navigating:', error: e);
      CustomSnackbar.showSnackBar(
          message:
              'An error occurred while trying to navigate. Please try again.');
    }
  }

  void _navigatetoadd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDishScreen(
          sqflite: widget.sqflite,
        ),
      ),
    );
    if (result != null) {
      CustomSnackbar.showSnackBar(message: result);
      setState(() {});
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
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomAppbar(
              title: 'Dishlist',
            ),
            const SizedBox(
              height: 40.0,
            ),
            Expanded(
              child: FutureBuilder<List<Dish>>(
                future: _handlefetchAllDishes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildDishList([], 'Indicator');
                  } else if (snapshot.hasError) {
                    return _buildDishList([], 'Error loading dishes');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildDishList([], 'No dishes available');
                  }

                  final dishes = snapshot.data!;
                  return _buildDishList(dishes, '');
                },
              ),
            ),
            const SizedBox(height: 8.0),
            CustomButtons.buildElevatedFunctionButton(
              context: context,
              onPressed: _navigatetoadd,
              text: 'Add',
            ),
            CustomButtons.buildElevatedFunctionButton(
                context: context,
                onPressed: () {
                  Navigator.pop(context, true);
                },
                text: 'Back'),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  Widget _buildDishHeader() {
    return Row(
      children: [
        _buildDishColumnHeader('Name', 0.15),
        _buildDishColumnHeader('Cal', 0.10),
        _buildDishColumnHeader('Protein', 0.15),
        _buildDishColumnHeader('Carbs', 0.15),
        _buildDishColumnHeader('Fat', 0.05),
        const Flexible(child: SizedBox()),
      ],
    );
  }

  Widget _buildDishColumnHeader(String title, double widthFactor) {
    return SizedBox(
      height: sizedBoxHeight,
      width: MediaQuery.of(context).size.width * widthFactor,
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDishRow(Dish dish) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          _buildDishColumn(dish.dish.toString(), 0.15),
          _buildDishColumn(dish.calories.toString(), 0.10),
          _buildDishColumn(dish.protein.toString(), 0.15),
          _buildDishColumn(dish.carbohydrates.toString(), 0.15),
          _buildDishColumn(dish.fat.toString(), 0.05),
          Flexible(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.greenAccent),
                  onPressed: () {
                    _navigateToEditDish(dish);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    _handleDeleteDish(dish.dish!, AuthProvider.of(context).id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishColumn(String text, double widthFactor) {
    return SizedBox(
      height: sizedBoxHeight,
      width: MediaQuery.of(context).size.width * widthFactor,
      child: Text(text),
    );
  }

  Widget _buildDishList(List<Dish> dishes, String message) {
    return CustomCards.buildListCard(
      context: context,
      child: Column(
        children: [
          _buildDishHeader(),
          const Divider(),
          Expanded(
            child: dishes.isNotEmpty
                ? ListView.builder(
                    itemCount: dishes.length,
                    itemBuilder: (context, index) {
                      final dish = dishes[index];
                      return _buildDishRow(dish);
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
