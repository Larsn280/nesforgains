import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/nutrition.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/dish_service.dart';
import 'package:nesforgains/service/nutrition_service.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:sqflite/sqflite.dart';

class DisplayDailyNutritionScreen extends StatefulWidget {
  final Database sqflite;

  const DisplayDailyNutritionScreen({super.key, required this.sqflite});

  @override
  State<DisplayDailyNutritionScreen> createState() =>
      _DisplayDailyNutritionScreenState();
}

class _DisplayDailyNutritionScreenState
    extends State<DisplayDailyNutritionScreen> {
  static const double sizedBoxHeight = 18.0;
  late DishService dishService;
  late NutritionService nutritionService;

  @override
  void initState() {
    super.initState();
    nutritionService = NutritionService(widget.sqflite);
  }

  Future<List<Nutrition>> _fetchDailyNutritionItems() async {
    try {
      final response = await nutritionService
          .fetchNutritionListByUserId(AuthProvider.of(context).id);
      return response;
    } catch (e) {
      logger.e('Error fetching daily nutrition', error: e);
      return [];
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
              title: 'Daily Nutrition List',
            ),
            const SizedBox(
              height: 40.0,
            ),
            Expanded(
              child: FutureBuilder<List<Nutrition>>(
                future: _fetchDailyNutritionItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildDailyNutritionList([], 'Indicator');
                  } else if (snapshot.hasError) {
                    return _buildDailyNutritionList(
                        [], 'Error loading daily nutrition');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildDailyNutritionList(
                        [], 'No daily nutrition available');
                  }

                  final dailyNutrition = snapshot.data!;
                  return _buildDailyNutritionList(dailyNutrition, '');
                },
              ),
            ),
            const SizedBox(height: 8.0),
            CustomButtons.buildElevatedFunctionButton(
                context: context,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                text: 'Home'),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyNutritionHeader() {
    return Row(
      children: [
        _buildNutritionColumnHeader('Date', 0.25),
        _buildNutritionColumnHeader('Cal', 0.10),
        _buildNutritionColumnHeader('Protein', 0.15),
        _buildNutritionColumnHeader('Carbs', 0.15),
        _buildNutritionColumnHeader('Fat', 0.10),
        const Flexible(child: SizedBox()),
      ],
    );
  }

  Widget _buildNutritionColumnHeader(String title, double widthFactor) {
    return SizedBox(
      height: sizedBoxHeight,
      width: MediaQuery.of(context).size.width * widthFactor,
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDailyNutritionRow(Nutrition dailyNutrition) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          _buildNutritionColumn(dailyNutrition.date!.toString(), 0.25),
          _buildNutritionColumn(dailyNutrition.calories.toString(), 0.10),
          _buildNutritionColumn(dailyNutrition.protein.toString(), 0.15),
          _buildNutritionColumn(dailyNutrition.carbohydrates.toString(), 0.15),
          _buildNutritionColumn(dailyNutrition.fat.toString(), 0.10),
          const Flexible(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildNutritionColumn(String text, double widthFactor) {
    return SizedBox(
      height: sizedBoxHeight,
      width: MediaQuery.of(context).size.width * widthFactor,
      child: Text(text),
    );
  }

  Widget _buildDailyNutritionList(
      List<Nutrition> dailyNutrition, String message) {
    return CustomCards.buildListCard(
      context: context,
      child: Column(
        children: [
          _buildDailyNutritionHeader(),
          const Divider(),
          Expanded(
            child: dailyNutrition.isNotEmpty
                ? ListView.builder(
                    itemCount: dailyNutrition.length,
                    itemBuilder: (context, index) {
                      final item = dailyNutrition[index];
                      return _buildDailyNutritionRow(item);
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
