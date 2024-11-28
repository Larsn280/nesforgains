import 'package:flutter/material.dart';
import 'package:nesforgains/constants.dart';
import 'package:nesforgains/logger.dart';
import 'package:nesforgains/service/auth_service.dart';
import 'package:nesforgains/service/scoreboard_service.dart';
import 'package:nesforgains/viewModels/userscore_viewmodel.dart';
import 'package:nesforgains/widgets/custom_appbar.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_cards.dart';
import 'package:nesforgains/widgets/custom_snackbar.dart';
import 'package:sqflite/sqflite.dart';

class DisplayScoreboardScreen extends StatefulWidget {
  final Database sqflite;

  const DisplayScoreboardScreen({super.key, required this.sqflite});

  @override
  State<DisplayScoreboardScreen> createState() =>
      _DisplayScoreboardScreenState();
}

class _DisplayScoreboardScreenState extends State<DisplayScoreboardScreen> {
  late Future<List<UserscoreViewmodel>> _futureScores;
  late ScoreboardService scoreboardService;
  late String username;

  @override
  void initState() {
    super.initState();
    username = AuthProvider.of(context).username;
    scoreboardService = ScoreboardService(widget.sqflite);
    _futureScores = _fetchAllScores();
  }

  Future<List<UserscoreViewmodel>> _fetchAllScores() async {
    try {
      await scoreboardService.updateUserScoresWithMaxLifts(username);
      final response =
          await scoreboardService.getAllExerciseScoresInDescendingOrder();
      return response;
    } catch (e) {
      logger.e('Error fetching scores', error: e);
      CustomSnackbar.showSnackBar(
          message:
              'An error occurred while fetching the scores. Please try again.');

      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppConstants.appbackgroundimage),
                fit: BoxFit.cover),
          ),
          child: Column(
            children: [
              const CustomAppbar(
                title: 'Scoreboard',
              ),
              const SizedBox(
                height: 40.0,
              ),
              Expanded(
                child: FutureBuilder<List<UserscoreViewmodel>>(
                  future: _futureScores,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildScoreboardList([], 'Indicator');
                    } else if (snapshot.hasError) {
                      return _buildScoreboardList([], 'Error loading scores');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildScoreboardList([], 'No scores available');
                    }

                    final scores = snapshot.data!;
                    return _buildScoreboardList(scores, '');
                  },
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              CustomButtons.buildElevatedFunctionButton(
                  context: context,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  text: 'Home'),
              const SizedBox(
                height: 20.0,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreboardList(List<UserscoreViewmodel> scores, String message) {
    return CustomCards.buildListCard(
      context: context,
      child: Column(
        children: [
          Expanded(
            child: scores.isNotEmpty
                ? ListView.builder(
                    itemCount: scores.length,
                    itemBuilder: (context, index) {
                      final score = scores[index];

                      return Card(
                        color: Colors.black54,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(
                                color: Colors.white, width: 1.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Column(
                                  children: [
                                    Text(
                                      'Nr: ${index + 1}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.35,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${score.name}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${score.date}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: SizedBox(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        score.exercise!,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${score.maxlift!.toString()} kg',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: message.startsWith('Indicator')
                        ? CircularProgressIndicator(
                            color: AppConstants.primaryTextColor,
                          )
                        : Text(message),
                  ),
          ),
        ],
      ),
    );
  }
}
