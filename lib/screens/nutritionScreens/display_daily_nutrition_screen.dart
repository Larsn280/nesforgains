import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/models/nutrition_data.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/dish_service.dart';
import 'package:nesforgains/service/nutrition_service.dart';
import 'package:nesforgains/widgets/custom_app_container.dart';
import 'package:nesforgains/widgets/custom_button.dart';
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

  Future<List<NutritionData>> _fetchDailyNutritionItems() async {
    try {
      final response = await nutritionService
          .fetchNutritionListByUserId(AuthProvider.of(context).loggedInUser.id);
      return response;
    } catch (e) {
      logger.e('Error fetching daily nutrition', error: e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppContainer(
      titleText: 'Näringslista',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 40.0,
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: FutureBuilder<List<NutritionData>>(
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
          CustomButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              text: 'Hem'),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Widget _buildDailyNutritionHeader() {
    return Row(
      children: [
        _buildNutritionColumnHeader('Datum', 0.20),
        _buildNutritionColumnHeader('Kal', 0.10),
        _buildNutritionColumnHeader('Protein', 0.15),
        _buildNutritionColumnHeader('Kolhydrater', 0.25),
        _buildNutritionColumnHeader('Fett', 0.10),
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

  Widget _buildDailyNutritionRow(NutritionData dailyNutrition) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          _buildNutritionColumn(dailyNutrition.date!.toString(), 0.20),
          _buildNutritionColumn(dailyNutrition.calories.toString(), 0.10),
          _buildNutritionColumn(dailyNutrition.protein.toString(), 0.15),
          _buildNutritionColumn(dailyNutrition.carbohydrates.toString(), 0.25),
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
      List<NutritionData> dailyNutrition, String message) {
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
