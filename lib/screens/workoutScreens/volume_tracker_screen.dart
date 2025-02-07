import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nesforgains/service/workout_service.dart';
import 'package:nesforgains/widgets/custom_app_container.dart';

import 'package:nesforgains/widgets/custom_back_navigation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fl_chart/fl_chart.dart';

class VolumeTrackerScreen extends StatefulWidget {
  final Database sqflite;
  const VolumeTrackerScreen({super.key, required this.sqflite});

  @override
  State<VolumeTrackerScreen> createState() => _VolumeTrackerScreen();
}

late WorkoutService workoutService;
List<FlSpot> workoutData = [];

class _VolumeTrackerScreen extends State<VolumeTrackerScreen> {
  @override
  void initState() {
    super.initState();
    workoutService = WorkoutService(widget.sqflite);
    loadWorkoutData();
  }

  Future<void> loadWorkoutData() async {
    final results = await workoutService.fetchWorkoutVolume();

    if (results.isEmpty) return;

    // Get the earliest date
    DateTime firstDate = DateTime.parse(results.first['day']); // Earliest date

    setState(() {
      workoutData = results
          .map((row) {
            try {
              if (row['day'] == null || row['totalVolume'] == null) {
                return null; // Skip invalid data
              }

              DateTime? parsedDate = DateTime.tryParse(row['day']);
              if (parsedDate == null) {
                return null; // Skip if date is invalid
              }

              // Calculate the x-axis value relative to the first date
              double dayIndex =
                  parsedDate.difference(firstDate).inDays.toDouble();
              double totalVolume = (row['totalVolume'] ?? 0).toDouble();

              // Skip invalid values
              if (dayIndex.isNaN ||
                  dayIndex.isInfinite ||
                  totalVolume.isNaN ||
                  totalVolume.isInfinite) {
                return null;
              }

              return FlSpot(dayIndex, totalVolume);
            } catch (e) {
              print("Error processing data: $e");
              return null;
            }
          })
          .whereType<FlSpot>()
          .toList(); // Remove any null values
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackNavigation(
      child: CustomAppContainer(
        titleText: 'Volym Spårare',
        child: Column(
          children: [
            const SizedBox(height: 40.0),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Colors.white, width: 1.0),
                color: Colors.black54,
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
              child: workoutData.isEmpty
                  ? const Center(
                      child: Text(
                        "No data available",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : SizedBox(
                      height: 300, // Set a fixed height
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: workoutData,
                              isCurved: false,
                              color: Colors.white,
                              barWidth: 3,
                            ),
                          ],
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              axisNameWidget: const Padding(
                                padding: EdgeInsets.only(
                                    bottom:
                                        10.0), // Adjust spacing from the grid
                                child: Text('Volym',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              axisNameSize: 32,
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize:
                                    50, // Use reservedSize for spacing

                                getTitlesWidget: (value, TitleMeta meta) {
                                  // Check if the value exists in workoutData
                                  bool hasValue = workoutData
                                      .any((spot) => spot.y == value);

                                  if (!hasValue) {
                                    return Container(); // Hide values that are not in the dataset
                                  }

                                  // Format values with "T" for trillion
                                  String formattedValue = value >= 1000
                                      ? '${(value / 1000).toStringAsFixed(0)}T' // Using string interpolation
                                      : value.toStringAsFixed(0);

                                  return Text(
                                    formattedValue,
                                    style: const TextStyle(fontSize: 10.0),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              axisNameWidget: const Text('Datum'),
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize:
                                    32, // Use reservedSize for spacing
                                getTitlesWidget: (value, TitleMeta meta) {
                                  // Check if the value exists in the data points
                                  bool hasValue = workoutData
                                      .any((spot) => spot.x == value);

                                  if (!hasValue) {
                                    return Container(); // Hide dates that have no corresponding values
                                  }
                                  // Get the actual date from the dayIndex
                                  DateTime date = DateTime.now()
                                      .add(Duration(days: value.toInt()));
                                  return Text(
                                    DateFormat('dd/MM').format(date),
                                    style: const TextStyle(fontSize: 10.0),
                                  ); // Format as dd/MM
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: false), // Hide top titles
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: false), // Hide right titles
                            ),
                            // Enable zooming and panning here
                          ),
                          lineTouchData: LineTouchData(
                            touchTooltipData: const LineTouchTooltipData(),
                            touchCallback: (FlTouchEvent event,
                                LineTouchResponse? touchResponse) {
                              // You can add extra logic here if needed
                            },
                            handleBuiltInTouches: true,
                          ),

                          // Configure zooming & panning
                          extraLinesData: const ExtraLinesData(),
                          clipData: const FlClipData.all(), //
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
